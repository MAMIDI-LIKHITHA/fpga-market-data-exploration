# Experimental Methodology

## 1. Principle
Compare architectures under identical logical workloads and measurement boundaries.

## 2. Latency statistics
For every workload collect:
- minimum
- mean
- median
- P95
- P99
- maximum
- standard deviation/jitter where meaningful

Tail latency matters because an architecture can have a lower mean while exhibiting larger outliers.

## 3. Timing analysis
Collect:
- achieved clock/Fmax
- WNS
- TNS
- critical paths
- setup/hold status

A design that cannot meet the target clock is not considered successful at that constraint.

## 4. Resource analysis
Collect LUT, FF, BRAM, DSP, and URAM where used. Calculate overhead relative to baseline.

## 5. Throughput
Measure maximum sustainable message rate before loss, backpressure, or correctness failure. Report workload conditions.

## 6. Reliability tests
Inject:
- missing sequence
- duplicate message
- out-of-order message
- Feed A interruption
- Feed B interruption
- malformed message

Record correctness, recovery behavior, latency impact, and resource overhead.

## 7. Verification
Use SystemVerilog assertions, directed tests, randomized traffic, Python golden reference, scoreboard comparison, reset/recovery tests, and boundary-value tests.

## 8. Statistical discipline
Use enough events to characterize each latency distribution. Retain the random seed for randomized workloads.

Each result records workload ID, seed, RTL commit, FPGA target, clock constraint, and tool version.

## 9. Comparison discipline
Do not compare results from different latency boundaries, clock assumptions, FPGA families, workloads, or protocol complexity as though they were directly equivalent.

Literature results are contextual benchmarks, not apples-to-apples measurements.
