# Phase 3 — Baseline Measurement

## Objective

Freeze a reproducible measurement contract for the first architecture before optimized alternatives are implemented.

## Simulation

1. Compile the RTL and golden testbench.
2. Require zero functional mismatches.
3. Capture latency for every output.
4. Parse the latency log.

## Latency

RX acceptance is in_valid && in_ready. TX observation is out_valid.

For clock period T_ns:

latency_ns = latency_cycles × T_ns

Do not convert cycles to nanoseconds using an assumed frequency.

## Workload matrix

Measure at minimum:
- sparse
- sustained
- burst
- mixed
- reliability/corner-case vectors

The same vectors must be reused for every architecture.

## Hardware metrics

After selecting the target FPGA, record:
- Fmax
- WNS
- TNS
- LUT
- FF
- BRAM
- DSP
- URAM where applicable

No board-specific timing/resource claim is made until a target FPGA and tool version are documented.

## Acceptance criteria

Phase 3 is complete when the golden test passes, latency samples are captured, the measurement boundary is documented, and synthesis/implementation results are archived separately from simulation results.
