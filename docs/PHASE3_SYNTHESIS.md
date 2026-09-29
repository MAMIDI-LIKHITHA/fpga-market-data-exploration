# Phase 3 — Baseline Synthesis and Implementation Measurement

## Objective

Measure the verified baseline on a reproducible FPGA implementation flow so that simulation latency is separated from implementation timing. The benchmark core RTL remains unchanged; a physical wrapper is used to expose the implementation interface without the internal 64-bit benchmark latency counter as a package I/O.

## Target and toolchain

- FPGA: Lattice ECP5 LFE5U-85F
- Package: CABGA756
- Speed grade: 8
- Toolchain: OSS CAD Suite
- Yosys: 0.69+156
- nextpnr-ecp5: 0.11.1-38-gc619da3d
- Clock constraint: 100 MHz (10.000 ns)
- SDC: constraints/ecp5_baseline.sdc
- Implementation top: ecp5_baseline_wrapper

## Implementation result

The baseline implementation successfully completed synthesis/technology mapping, placement, and routing on the selected ECP5 target.

### Resource utilization

| Resource | Used | Available | Utilization |
|---|---:|---:|---:|
| LUT4 | 19,056 | 83,640 | 22% |
| FF | 4,452 | 83,640 | 5% |
| TRELLIS_IO | 327 | 365 | 89% |
| BRAM / DP16KD | 0 | 208 | 0% |
| DSP / MULT18X18D | 0 | 156 | 0% |
| ALU54B | 0 | 78 | 0% |

The design therefore fits the selected device, although top-level I/O utilization is high at 89%.

### Timing result

The SDC clock constraint was recognized by nextpnr: constraining clock net clk to 100.00 MHz.

The final report contains two relevant timing paths:

1. Internal clocked path:
   - Logic delay: **2.88 ns**
   - Routing delay: **26.56 ns**
   - Total reported path: **29.44 ns**
   - Endpoint: flip-flop clock-enable (CE)

2. Clock-to-output path:
   - Clock-to-Q: **0.40 ns**
   - Routing delay: **7.45 ns**
   - Total: **7.84 ns**
   - Endpoint: out_best_ask[21]

nextpnr also reports:
- <async> -> posedge clk: **29.44 ns**
- posedge clk -> <async>: **7.84 ns**
- Reported Fmax: **3.19 MHz**
- 100 MHz constraint: **FAIL**
- Warnings: **0**
- Errors: **1 timing error**
- Program finished normally.

### Timing interpretation

The reported **3.19 MHz Fmax must not be treated as the intrinsic synchronous Fmax of the market-data processing pipeline**. The report's timing endpoints include <async> I/O paths, while the displayed 29.44 ns path ends at a flip-flop CE and the 7.84 ns path ends at a top-level output.

The 29.44 ns path by itself corresponds to approximately 34 MHz, so it does not mathematically explain the reported 3.19 MHz value. The current result is therefore recorded as an **I/O/asynchronous timing-dominated implementation result**, not as a clean register-to-register Fmax benchmark.

Before comparing architectures by Fmax, the timing methodology should be refined to isolate synchronous register-to-register paths and define input/output timing assumptions consistently.

## Latency

Phase 2 functional verification measured **1 cycle** at the simulation testbench boundary for the verified workload. This must remain separate from FPGA physical timing.

For a future implemented-clock latency measurement:

latency_ns = latency_cycles × implemented_clock_period_ns

No FPGA nanosecond latency claim is made from the current 1-cycle simulation result.

## Reproducibility

The functional baseline was previously verified against 1,000 deterministic mixed-workload vectors with 0 failures and 0 timeouts. The implementation uses the same baseline core and a physical wrapper only for package-level I/O feasibility.

The implementation constraint is stored in constraints/ecp5_baseline.sdc.

## Current conclusion

Phase 3 has established a reproducible ECP5 synthesis/placement/routing baseline and exposed an important implementation bottleneck: the current order-book logic is LUT-heavy and routing-heavy, while the physical interface consumes 89% of available I/O resources. Timing closure at the 100 MHz target has not been achieved.

The next Phase 3 task is to refine timing constraints/reporting enough to obtain a clean synchronous timing metric. Only then should the architectural alternatives be compared against the baseline.