#!/usr/bin/env python3
"""Generate a deterministic input workload and golden reference output."""

from __future__ import annotations

from dataclasses import asdict
import argparse
import json
from pathlib import Path
import sys

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from reference_model import read_events, write_reference_outputs
from traffic_generator import generate_workload


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--count", type=int, default=100)
    parser.add_argument("--seed", type=int, default=20260929)
    parser.add_argument("--mode", choices=("sparse", "sustained", "burst", "mixed"), default="mixed")
    parser.add_argument("--input", type=Path, default=Path("data/workloads/mixed_100.jsonl"))
    parser.add_argument("--expected", type=Path, default=Path("data/workloads/mixed_100_expected.jsonl"))
    args = parser.parse_args()

    events = generate_workload(args.count, args.seed, args.mode)

    args.input.parent.mkdir(parents=True, exist_ok=True)
    with args.input.open("w", encoding="utf-8") as handle:
        for event in events:
            handle.write(json.dumps(asdict(event), sort_keys=True) + "\n")

    count = write_reference_outputs(read_events(args.input), args.expected)
    print(f"Generated {count} golden-vector entries")
    print(f"Input: {args.input}")
    print(f"Expected: {args.expected}")


if __name__ == "__main__":
    main()
