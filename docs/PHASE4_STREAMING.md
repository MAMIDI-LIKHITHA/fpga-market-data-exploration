# Phase 4A — Streaming / Cut-Through Architecture

## Objective

Implement the first streaming/cut-through architecture as a controlled Phase 4 variant of the verified baseline.

The streaming architecture removes any packet-store stage between ingress and order-book processing. A market event is parsed directly from the accepted 128-bit input and consumed by the order book without waiting for a packet buffer transaction.

## Important baseline observation

The current Phase 3 baseline already has a direct event-to-order-book path and does not contain a separate packet-buffer RTL module. Therefore, this Phase 4A implementation is primarily an explicit architectural organization of the existing cut-through behavior, not a claim of a large hardware transformation.

This distinction is important for a rigorous comparison: the experiment must not claim a latency improvement merely because the architecture is named streaming.

## Controlled implementation

- Event format: unchanged 128-bit format
- Order-book depth: 64
- Strategy/risk behavior: unchanged
- Golden workload: existing 1,000-vector mixed workload
- Reference model: unchanged
- Output semantics: unchanged
- Packet-buffer stage: none
- Additional pipeline registers in the data path: none

RTL: rtl/streaming/streaming_market_pipeline.sv

## Benchmark rule

Phase 4A is a functional/architectural control experiment.

Before reporting any latency/resource/timing difference, run the same:
1. 1,000-vector golden verification
2. ECP5 synthesis and technology mapping
3. Placement and routing
4. 100 MHz SDC timing analysis
5. Resource extraction

If results are effectively identical to the baseline, that is itself a valid result: it demonstrates that the current baseline data path is already cut-through at the event level.

## Research integrity

Do not describe Phase 4A as a performance improvement until implementation measurements demonstrate one.

Do not change the Python reference model or workload when comparing architectures.
