#!/usr/bin/env python3
"""Generate deterministic synthetic market-data JSONL workloads."""

from __future__ import annotations

from dataclasses import asdict
import argparse
import json
from pathlib import Path
import random
import sys

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
from reference_model import MarketEvent


def generate_workload(count: int, seed: int, mode: str = "mixed") -> list[MarketEvent]:
    rng = random.Random(seed)
    active: dict[int, tuple[str, int, int]] = {}
    next_order_id = 1
    events: list[MarketEvent] = []

    add_probability = {
        "sparse": 0.45,
        "sustained": 0.55,
        "burst": 0.60,
        "mixed": 0.50,
    }[mode]

    for sequence in range(1, count + 1):
        if not active or rng.random() < add_probability:
            side = rng.choice(("BUY", "SELL"))
            price = rng.randint(9990, 10010)
            quantity = rng.randint(1, 25)
            order_id = next_order_id
            next_order_id += 1
            active[order_id] = (side, price, quantity)
            event_type = "ADD"
        else:
            order_id = rng.choice(list(active))
            old_side, old_price, old_quantity = active[order_id]
            roll = rng.random()

            if roll < 0.40:
                event_type = "CANCEL"
                side, price, quantity = old_side, old_price, old_quantity
                del active[order_id]
            elif roll < 0.70:
                event_type = "MODIFY"
                side = rng.choice(("BUY", "SELL"))
                price = rng.randint(9990, 10010)
                quantity = rng.randint(1, 25)
                active[order_id] = (side, price, quantity)
            else:
                event_type = "TRADE"
                side, price = old_side, old_price
                quantity = rng.randint(1, old_quantity)
                remaining = old_quantity - quantity
                if remaining:
                    active[order_id] = (old_side, old_price, remaining)
                else:
                    del active[order_id]

        events.append(MarketEvent(
            type=event_type,
            sequence=sequence,
            side=side,
            order_id=order_id,
            price=price,
            quantity=quantity,
        ))

    return events


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--count", type=int, default=100)
    parser.add_argument("--seed", type=int, default=20260929)
    parser.add_argument("--mode", choices=("sparse", "sustained", "burst", "mixed"), default="mixed")
    parser.add_argument("--output", type=Path, default=Path("data/workloads/mixed_100.jsonl"))
    args = parser.parse_args()

    if args.count <= 0:
        raise SystemExit("--count must be positive")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    events = generate_workload(args.count, args.seed, args.mode)

    with args.output.open("w", encoding="utf-8") as handle:
        for event in events:
            handle.write(json.dumps(asdict(event), sort_keys=True) + "\n")

    print(f"Generated {len(events)} events -> {args.output}")


if __name__ == "__main__":
    main()
