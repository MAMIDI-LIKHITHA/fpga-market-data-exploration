# Baseline Golden Verification — 1000 Vectors

## Verification status

**PASS — 1000/1000 vectors matched the Python golden reference with zero failures and zero timeouts.**

Date of recorded run: 2026-09-29

## Test configuration

- DUT: `rtl/baseline/baseline_market_pipeline.sv`
- Order-book implementation: `rtl/baseline/order_book.sv`
- Testbench: `tb/sv/tb_baseline_golden.sv`
- Workload: `data/workloads/events.jsonl`
- Golden reference: `data/workloads/expected.jsonl`
- Simulation vectors: 1,000
- Generator seed: 42
- Workload mode: mixed
- Golden-memory files: `data/workloads/events.mem` and `data/workloads/expected.mem`
- ModelSim: Intel FPGA Edition 2021.1
- Testbench timeout: 100 cycles

## Result

| Metric | Result |
|---|---:|
| Vectors checked | 1,000 |
| Failures | 0 |
| Timeouts | 0 |
| Golden mismatches | 0 |
| Reported transaction latency | 1 cycle |
| Simulation finish time | 30,045 ps |

The testbench reached vector 999 successfully and terminated through the intended `$finish` statement.

## Interpretation

The baseline RTL produced outputs matching the Python reference model for the complete 1,000-event mixed workload. This establishes functional agreement between the software reference and the current baseline RTL for this deterministic workload.

The reported **1-cycle latency** is a simulation-level transaction latency measurement from the current testbench boundary. It is **not** an FPGA implementation timing result and must not be interpreted as Fmax or physical nanosecond latency.

The next measurement stage is synthesis and implementation on a selected FPGA target, followed by automated extraction of timing and resource metrics.

## Reproduction

```text
python scripts\generate_golden_vectors.py --count 1000 --seed 42 --mode mixed --input data\workloads\events.jsonl --expected data\workloads\expected.jsonl
python scripts\jsonl_to_mem.py data\workloads\events.jsonl data\workloads\expected.jsonl
vlog rtl/market_event_pkg.sv
vlog rtl/baseline/order_book.sv
vlog rtl/baseline/baseline_market_pipeline.sv
vlog tb/sv/tb_baseline_golden.sv
vsim work.tb_baseline_golden
run -all
```

## Recorded output

The complete ModelSim output is preserved in `docs/results/baseline_golden_1000.log`.
