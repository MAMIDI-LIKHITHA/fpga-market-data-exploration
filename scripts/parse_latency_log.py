#!/usr/bin/env python3
from __future__ import annotations
import argparse
import re
import statistics
from pathlib import Path

PATTERN = re.compile(r"latency=(\d+)")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("log", type=Path)
    args = parser.parse_args()
    samples = [int(x) for x in PATTERN.findall(args.log.read_text(encoding="utf-8"))]
    if not samples:
        raise SystemExit("No latency samples found")
    print(f"count={len(samples)}")
    print(f"min_cycles={min(samples)}")
    print(f"mean_cycles={statistics.mean(samples):.3f}")
    print(f"median_cycles={statistics.median(samples):.3f}")
    print(f"max_cycles={max(samples)}")
    if len(samples) > 1:
        print(f"stdev_cycles={statistics.pstdev(samples):.3f}")

if __name__ == "__main__":
    main()
