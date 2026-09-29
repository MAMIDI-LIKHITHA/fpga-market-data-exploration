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

The final timing report contains three relevant path classes:

1. **Synchronous register-to-register critical path**
   - Total delay: **313.064 ns**
   - Reported Fmax: **3.194 MHz**
   - This is the path that determines the reported synchronous clock frequency.
   - The path is dominated by the combinational best-price/order-book path and downstream comparison/arithmetic, including substantial routing and carry-chain delay.

2. **Input/I/O timing path**
   - `<async> -> posedge clk`: **29.442 ns**
   - This is an I/O timing path, not the synchronous pipeline critical path.

3. **Clock-to-output I/O path**
   - `posedge clk -> <async>`: **7.845 ns**
   - Example endpoint: `out_best_ask[21]`.

The critical-path report for the synchronous path shows substantial routing delay and a long carry-chain/combinational path associated with the order-book best-price logic and downstream logic in `baseline_market_pipeline.sv`.

nextpnr reports:
- Synchronous critical-path delay: **313.064 ns**
- Fmax: **3.194 MHz**
- 100 MHz constraint: **FAIL**
- Warnings: **0**
- Errors: **1 timing error**
- Program finished normally.

At 100 MHz, the target period is 10 ns, so the measured synchronous path is far beyond the requested period. The current baseline therefore does not achieve 100 MHz timing closure.

### Timing interpretation

The **313.064 ns clock-to-clock path is the actual synchronous critical path** and explains the reported 3.194 MHz Fmax:

Fmax ≈ 1 / 313.064 ns ≈ **3.194 MHz**

The previously reported 29.442 ns and 7.845 ns values are separate I/O timing paths and should not be used as the synchronous Fmax calculation.

This distinction is important: simulation transaction latency and physical FPGA timing measure different things. A transaction can require one simulated clock cycle while the implemented design still has a long register-to-register critical path that limits the maximum clock frequency.

The baseline order book uses a deliberately simple combinational best-price scan across the order-book entries. This provides a useful stress case for architectural exploration, but it is not intended to represent an optimized production HFT order-book implementation.

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

Phase 3 is now closed. The synchronous timing metric has been isolated and documented separately from the I/O timing paths. Phase 4 can begin with the streaming/cut-through architecture, using this baseline as the controlled reference.