# Design-Space Exploration of Deterministic Ultra-Low-Latency FPGA Architectures for Market Data Processing

Research and RTL project exploring how FPGA architecture choices affect latency, determinism, throughput, timing closure, resource utilization, reliability, and verification complexity in a simulated market-data-to-order pipeline.

## Research question
How do buffering, cut-through processing, pipelining, parallelism, feed arbitration, and memory organization affect end-to-end latency and determinism while maintaining practical FPGA resource usage, timing closure, reliability, and verifiability?

## Objective
Build the same controlled market-data workload using multiple FPGA architectures and measure the trade-offs rather than assuming that the lowest average latency is always the best architecture.

## Planned architectures
1. Buffered/store-and-forward baseline: RX -> Packet Buffer -> Parser -> Order Book -> Strategy -> Risk -> TX
2. Streaming/cut-through: RX -> Parser -> Order Book -> Strategy -> Risk -> TX
3. Parallelized pipeline: parallel parsing and selected processing stages followed by deterministic aggregation
4. Hybrid: cut-through processing + pipelining + selected parallelism + carefully placed buffering
5. A/B feed arbitration experiment with configurable latency-oriented and reliability-oriented behavior

## Measurement plan
Latency: minimum, average, median, P95, P99, worst case, jitter, end-to-end RX-to-TX latency.
Implementation: Fmax, WNS, TNS, critical path, LUT, FF, BRAM, DSP/URAM where applicable.
Performance: throughput and message rate.
Robustness: sequence gaps, duplicates, out-of-order messages, feed failure/recovery.
Verification: SystemVerilog assertions, Python golden model, randomized traffic, directed corner cases, RTL/reference comparison.

## Initial market-data message
The first prototype uses a deterministic, simplified exchange-feed-inspired format:
- Message type: 8 bits
- Sequence number: 32 bits
- Side: 1 bit
- Order ID: 16 bits
- Price: 32 bits
- Quantity: 32 bits

Message types: ADD_ORDER, CANCEL_ORDER, MODIFY_ORDER, TRADE.

This is a research abstraction, not a claim to reproduce a proprietary exchange protocol.

## Processing pipeline
Market event -> protocol parsing -> order-book update -> best bid/ask -> strategy signal -> risk gate -> order generation.

The strategy is intentionally simple. It creates a deterministic downstream workload; the research contribution is the architectural and measurement study.

## Experimental principle
A faster clock does not automatically mean lower end-to-end latency. Latency will be analyzed in cycles and nanoseconds together with pipeline depth and timing results.

Example: 250 MHz x 5 cycles = 20 ns, while 400 MHz x 12 cycles = 30 ns.

## Literature positioning
Prior research has demonstrated FPGA acceleration for market-data feed handling, FAST decoding, feed arbitration, order-book construction, and low-latency trading systems. This project does not assume those concepts are individually new.

The intended contribution is a reproducible, controlled comparison of multiple architectures under the same workload, emphasizing end-to-end latency, tail latency, determinism, latency versus reliability, resource utilization, timing closure, and verification complexity.

## Roadmap
- [x] Define research scope
- [x] Define architecture candidates
- [x] Define measurement methodology
- [x] Define simplified market-data format
- [x] Build Python traffic generator
- [x] Build Python golden order-book model
- [x] Build baseline SystemVerilog RTL
- [x] Build baseline testbench and golden comparison
- [x] Establish cycle-accurate latency instrumentation
- [ ] Synthesize baseline and collect timing/resource reports
- [ ] Implement streaming architecture
- [ ] Implement parallel architecture
- [ ] Implement hybrid architecture
- [ ] Add A/B feed reliability experiments
- [ ] Run controlled workload matrix
- [ ] Analyze results
- [ ] Complete literature review
- [ ] Write research paper

## Status
Phase 2 — Baseline RTL functionally verified.

The baseline RTL matches the Python golden reference for 1,000 deterministic mixed-workload vectors with 0 failures and 0 timeouts. The current simulation reports 1-cycle transaction latency at the testbench boundary. This is not an FPGA implementation timing result; synthesis and implementation measurements are still pending.

Verification details: docs/PHASE2_VERIFICATION.md

## Author
Mamidi Likhitha
