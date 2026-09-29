# Project Specification v1.0

## 1. System objective
Develop and experimentally compare FPGA architectures for deterministic, ultra-low-latency processing of exchange-feed-like market events.

The implementation is simulated and educational/research-oriented. It does not connect to a live exchange and does not attempt to reproduce proprietary production infrastructure.

## 2. Research question
How do buffering, cut-through processing, pipelining, parallelism, feed arbitration, and memory organization change:
- end-to-end latency
- tail latency
- deterministic behavior
- throughput
- timing closure
- FPGA resource utilization
- reliability
- verification complexity

## 3. Hypotheses
These are hypotheses, not conclusions:
1. Removing unnecessary store-and-forward buffering can reduce pipeline latency.
2. Parallelism can improve throughput but increase resource use and potentially make timing closure harder.
3. Lower average latency does not necessarily imply lower P99 or worst-case latency.
4. Reliability mechanisms can introduce latency/resource overhead.
5. A hybrid architecture may provide a different balance among latency, determinism, resource use, reliability, and verification effort.

## 4. Functional blocks
Feed RX: accepts generated market-data messages and records an ingress timestamp.
Feed arbitration: optional dual-feed block that detects duplicates/sequence conditions and selects a usable feed event.
Protocol parser: extracts message fields.
Order book: maintains state needed to derive best bid and best ask.
Strategy: produces a candidate trading action from current book state.
Risk gate: applies deterministic position/order limits.
Order generator: creates a simplified outbound order and records an egress timestamp.

## 5. Latency definition
Primary latency metric:
L_cycles = egress_cycle - ingress_cycle
L_ns = L_cycles x clock_period_ns

Both cycle count and nanoseconds will be reported.

## 6. Workloads
- Low-rate sparse traffic
- Sustained traffic
- Burst traffic
- Mixed ADD/CANCEL/MODIFY/TRADE traffic
- Repeated same-price activity
- Sequence-gap/error traffic
- Duplicate/out-of-order traffic

Exact message counts and offered rates will be fixed before each comparison and reused across architectures.

## 7. Fair comparison rules
- Same logical functionality
- Same input workload
- Same clock constraint
- Same output definition
- Same latency boundary
- Same correctness criteria
- Same synthesis target where possible
- No architecture-specific omission of required processing

If targets differ, results are reported separately rather than treated as directly equivalent.

## 8. Result record
Each result should contain:
architecture, target device, clock constraint, workload ID, message count, latency statistics, throughput, LUT/FF/BRAM/DSP/URAM, Fmax, WNS/TNS, and verification status.

## 9. Reproducibility
Every result should be traceable to workload -> RTL commit -> tool settings -> synthesis report -> analysis script -> result table.

No benchmark values are fabricated. Empty result fields remain empty until measured.

## 10. Research contribution boundary
The project will not claim that FPGA acceleration, cut-through processing, feed arbitration, order-book acceleration, or pipelining are individually novel.

Novelty, if any, will be claimed only after deeper literature review and experimental validation.

## 11. Success criteria
1. Functionally verified RTL for at least two architectures.
2. Python reference model and reproducible workload generator.
3. Cycle-accurate latency measurements.
4. FPGA synthesis/timing/resource reports.
5. Controlled comparison with tail-latency analysis.
6. Reliability experiments.
7. Literature-grounded discussion of results and limitations.
