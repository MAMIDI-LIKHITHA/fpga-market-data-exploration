# Phase 2 — Baseline SystemVerilog

The baseline is the first hardware implementation of the Phase 1 functional specification. It is intentionally straightforward rather than latency-optimized.

## Datapath

RX event -> order-book update -> best bid/ask scan -> synthetic strategy -> risk gate -> output

The event is a 128-bit word defined in docs/PROTOCOL.md.

## Baseline assumptions

- 64 logical order slots.
- order_id directly indexes the research memory.
- Best bid/ask are derived by a combinational scan of all slots.
- One event is accepted whenever in_valid and in_ready are asserted.
- Timestamp difference is reported in clock cycles.
- The current implementation is a functional baseline, not a final timing-optimized design.

## Why this baseline matters

The full best-price scan intentionally exposes a likely architectural cost. Later streaming, pipelined, parallel and hybrid versions can replace this mechanism while preserving the same external workload and measurement boundary.

## Verification

tb/sv/tb_baseline_market_pipeline.sv is a smoke test for ADD, CANCEL, TRADE and MODIFY.

The next verification step is automatic comparison against the Python golden JSONL vectors. FPGA implementation reports will then provide Fmax, WNS, TNS and resource utilization.

## Latency boundary

Latency is measured from acceptance of an event at the RX boundary to the corresponding output event at the TX boundary. Report both cycles and nanoseconds.
