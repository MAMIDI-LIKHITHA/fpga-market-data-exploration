# Architecture

## Reference data path
Market Data
  -> Feed RX
  -> Feed Arbitration (optional)
  -> Protocol Parser
  -> Order Book
  -> Strategy
  -> Risk Gate
  -> Order Generator
  -> Market/Exchange Simulator

## Architecture A — Buffered baseline
RX -> Packet Buffer -> Parser -> Order Book -> Strategy -> Risk -> TX

Purpose:
- Establish a conventional reference implementation.
- Make buffering overhead measurable.
- Provide the baseline for all later comparisons.

## Architecture B — Streaming / cut-through
RX -> Parser -> Order Book -> Strategy -> Risk -> TX

Purpose:
- Investigate whether downstream processing can begin before a complete message is stored.
- Study control, timing, and verification consequences.

## Architecture C — Parallel
RX -> Parallel parsing/processing lanes -> deterministic aggregation -> Order Book -> Strategy -> Risk/TX

Purpose:
- Study throughput, resource, routing, and timing trade-offs from parallel work.

## Architecture D — Hybrid
RX -> Cut-through Parser -> Pipelined Order Book -> Parallel Strategy/Risk -> TX

Purpose:
- Combine only optimizations justified by measurements.
- Evaluate whether combined optimizations create routing congestion or verification complexity.

## A/B feed experiment
Feed A ----+
           +--> Arbitration -> Parser -> Processing
Feed B ----+

Possible modes:
- latency-oriented selection
- reliability-oriented selection

Exact arbitration rules will be documented before benchmarking.

## Measurement boundary
Primary end-to-end measurement:
ingress timestamp -> accepted market event -> processing pipeline -> emitted order -> egress timestamp

Module-level measurements may also be reported, but must not be confused with end-to-end latency.
