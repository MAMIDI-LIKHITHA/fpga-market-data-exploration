#!/usr/bin/env python3
"""Convert Phase 1 JSONL vectors into Verilog $readmemh files."""

from __future__ import annotations
import argparse
import json
from pathlib import Path

NONE = 0xFFFFFFFF

def event_word(event: dict) -> int:
    types = {"ADD": 1, "CANCEL": 2, "MODIFY": 3, "TRADE": 4}
    sides = {"BUY": 0, "SELL": 1}
    return (
        (types[event["type"]] & 0xFF) << 120
        | (event["sequence"] & 0xFFFFFFFF) << 88
        | (sides[event["side"]] & 1) << 87
        | (event["order_id"] & 0xFFFF) << 64
        | (event["price"] & 0xFFFFFFFF) << 32
        | (event["quantity"] & 0xFFFFFFFF)
    )

def state_word(state: dict) -> int:
    def value(name: str) -> int:
        x = state[name]
        return NONE if x is None else int(x)

    return (
        (int(state["sequence"]) & 0xFFFFFFFF) << 224
        | value("best_bid") << 192
        | value("best_ask") << 160
        | value("spread") << 128
        | (int(state["position"]) & 0xFFFFFFFF) << 96
        | value("output_price") << 64
        | (int(state["output_quantity"]) & 0xFFFFFFFF) << 32
        | (int(state["signal"]) & 1) << 31
        | (int(state["risk_accept"]) & 1) << 30
    )

def write_words(path: Path, words: list[int], width: int) -> None:
    digits = (width + 3) // 4
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for word in words:
            f.write(f"{word:0{digits}X}\n")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("events", type=Path)
    parser.add_argument("expected", type=Path)
    parser.add_argument("--events-out", type=Path, default=Path("data/workloads/events.mem"))
    parser.add_argument("--expected-out", type=Path, default=Path("data/workloads/expected.mem"))
    args = parser.parse_args()

    events = [json.loads(line) for line in args.events.read_text(encoding="utf-8").splitlines() if line.strip()]
    expected = [json.loads(line) for line in args.expected.read_text(encoding="utf-8").splitlines() if line.strip()]
    if len(events) != len(expected):
        raise ValueError("Event and expected-vector counts differ")

    write_words(args.events_out, [event_word(x) for x in events], 128)
    write_words(args.expected_out, [state_word(x) for x in expected], 256)
    print(f"Wrote {len(events)} event vectors and {len(expected)} expected vectors")

if __name__ == "__main__":
    main()
