#!/usr/bin/env python3
"""Deterministic software reference model for the FPGA market-data study."""

from __future__ import annotations

from dataclasses import asdict, dataclass
import json
from pathlib import Path
from typing import Dict, Iterable, Optional


MESSAGE_TYPES = {"ADD": 1, "CANCEL": 2, "MODIFY": 3, "TRADE": 4}
SPREAD_THRESHOLD = 5
MIN_ORDER_QTY = 1
MAX_POSITION = 100


@dataclass(frozen=True)
class MarketEvent:
    type: str
    sequence: int
    side: str
    order_id: int
    price: int
    quantity: int


@dataclass(frozen=True)
class BookState:
    sequence: int
    best_bid: Optional[int]
    best_ask: Optional[int]
    spread: Optional[int]
    position: int
    signal: int
    risk_accept: int
    output_price: Optional[int]
    output_quantity: int


class ReferenceModel:
    def __init__(
        self,
        spread_threshold: int = SPREAD_THRESHOLD,
        min_order_qty: int = MIN_ORDER_QTY,
        max_position: int = MAX_POSITION,
    ) -> None:
        self.orders: Dict[int, MarketEvent] = {}
        self.position = 0
        self.spread_threshold = spread_threshold
        self.min_order_qty = min_order_qty
        self.max_position = max_position

    def _validate_event(self, event: MarketEvent) -> None:
        if event.type not in MESSAGE_TYPES:
            raise ValueError(f"Unsupported message type: {event.type}")
        if event.side not in {"BUY", "SELL"}:
            raise ValueError(f"Unsupported side: {event.side}")
        if not 0 <= event.sequence <= 0xFFFFFFFF:
            raise ValueError("Sequence must fit in 32 bits")
        if not 0 <= event.order_id <= 0xFFFF:
            raise ValueError("Order ID must fit in 16 bits")
        if not 0 <= event.price <= 0xFFFFFFFF:
            raise ValueError("Price must fit in 32 bits")
        if not 0 <= event.quantity <= 0xFFFFFFFF:
            raise ValueError("Quantity must fit in 32 bits")
        if event.type in {"ADD", "MODIFY"} and event.quantity == 0:
            raise ValueError(f"{event.type} quantity must be non-zero")

    def _best_prices(self) -> tuple[Optional[int], Optional[int]]:
        bids = [o.price for o in self.orders.values()
                if o.side == "BUY" and o.quantity > 0]
        asks = [o.price for o in self.orders.values()
                if o.side == "SELL" and o.quantity > 0]
        return (max(bids) if bids else None, min(asks) if asks else None)

    def _apply_book_update(self, event: MarketEvent) -> None:
        existing = self.orders.get(event.order_id)

        if event.type == "ADD":
            if existing is not None:
                raise ValueError(f"ADD for active order {event.order_id}")
            self.orders[event.order_id] = event

        elif event.type == "CANCEL":
            if existing is not None:
                del self.orders[event.order_id]

        elif event.type == "MODIFY":
            if existing is None:
                raise ValueError(f"MODIFY for unknown order {event.order_id}")
            self.orders[event.order_id] = event

        elif event.type == "TRADE":
            if existing is None:
                return
            remaining = max(0, existing.quantity - event.quantity)
            if remaining == 0:
                del self.orders[event.order_id]
            else:
                self.orders[event.order_id] = MarketEvent(
                    type=existing.type,
                    sequence=existing.sequence,
                    side=existing.side,
                    order_id=existing.order_id,
                    price=existing.price,
                    quantity=remaining,
                )

    def process(self, event: MarketEvent) -> BookState:
        self._validate_event(event)
        self._apply_book_update(event)

        best_bid, best_ask = self._best_prices()
        # Match the baseline RTL semantics: an incomplete book reports spread=0,
        # while a crossed book (best ask < best bid) does not generate a signal.
        spread = best_ask - best_bid if best_bid is not None and best_ask is not None else 0
        signal = int(
            best_bid is not None
            and best_ask is not None
            and best_ask >= best_bid
            and spread <= self.spread_threshold
        )
        output_price = best_bid if signal else None
        output_quantity = self.min_order_qty if signal else 0
        risk_accept = int(signal and self.position + output_quantity <= self.max_position)

        if risk_accept:
            self.position += output_quantity

        return BookState(
            sequence=event.sequence,
            best_bid=best_bid,
            best_ask=best_ask,
            spread=spread,
            position=self.position,
            signal=signal,
            risk_accept=risk_accept,
            output_price=output_price,
            output_quantity=output_quantity if risk_accept else 0,
        )


def read_events(path: Path) -> Iterable[MarketEvent]:
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            if not line.strip():
                continue
            try:
                yield MarketEvent(**json.loads(line))
            except (json.JSONDecodeError, TypeError) as exc:
                raise ValueError(f"Invalid event on line {line_number}: {exc}") from exc


def write_reference_outputs(events: Iterable[MarketEvent], output_path: Path) -> int:
    model = ReferenceModel()
    count = 0
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open("w", encoding="utf-8") as handle:
        for event in events:
            handle.write(json.dumps(asdict(model.process(event)), sort_keys=True) + "\n")
            count += 1
    return count


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    print(f"Processed {write_reference_outputs(read_events(args.input), args.output)} events")
