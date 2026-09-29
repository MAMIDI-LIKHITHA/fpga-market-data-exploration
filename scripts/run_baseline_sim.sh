#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
BUILD="$ROOT/build"
mkdir -p "$BUILD"

iverilog -g2012 -o "$BUILD/baseline_tb.vvp" \
  "$ROOT/rtl/market_event_pkg.sv" \
  "$ROOT/rtl/baseline/order_book.sv" \
  "$ROOT/rtl/baseline/baseline_market_pipeline.sv" \
  "$ROOT/tb/sv/tb_baseline_golden.sv"

vvp "$BUILD/baseline_tb.vvp" | tee "$BUILD/baseline_sim.log"
