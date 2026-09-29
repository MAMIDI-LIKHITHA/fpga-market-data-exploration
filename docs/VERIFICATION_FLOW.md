# Phase 2 Verification Flow

## Golden-vector boundary

The Python reference model remains the behavioral source of truth. The hardware testbench consumes the same event semantics and checks the resulting sequence, best prices, spread, strategy signal, risk decision, output price and output quantity.

The conversion script scripts/jsonl_to_mem.py maps JSONL vectors to Verilog memory words:
- input event: 128 bits
- expected state: 256 bits

The expected-state encoding uses 0xFFFFFFFF as the sentinel for an absent optional value.

## Current smoke test

tb/sv/tb_baseline_golden.sv is the golden comparison testbench. It was used to verify 1,000 deterministic mixed-workload vectors covering ADD, MODIFY, TRADE and CANCEL cases, including signal and no-signal cases.

## Reproducible flow

1. Generate a clean workload with the Phase 1 traffic generator.
2. Run the Python reference model to produce expected JSONL.
3. Convert both JSONL files with scripts/jsonl_to_mem.py.
4. Run the SystemVerilog simulation.
5. Compare every output field at the same RX-to-TX measurement boundary.
6. Record latency cycles and, after synthesis/implementation, convert cycles to nanoseconds using the achieved clock period.

## Verified baseline result

The 2026-09-29 ModelSim run checked all 1,000 vectors with 0 failures and 0 timeouts. The observed transaction latency was 1 cycle for every reported PASS vector. See docs/PHASE2_VERIFICATION.md for the archived output.

## Research rule

A hardware optimization is accepted into the architecture comparison only when it preserves the same functional outputs for the same input vectors.
