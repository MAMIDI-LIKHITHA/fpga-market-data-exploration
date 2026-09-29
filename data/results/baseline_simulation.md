# Baseline Simulation Record

Status: pending local simulator execution.

Run from the repository root:

    bash scripts/run_baseline_sim.sh
    python3 scripts/parse_latency_log.py build/baseline_sim.log

Measurement boundary:
- RX timestamp: cycle where in_valid && in_ready accepts an event.
- TX timestamp: cycle where out_valid presents the corresponding output.
- Latency: TX timestamp minus RX timestamp.

Nanoseconds must only be reported after a clock period has been selected.

Synthesis fields are pending until a target FPGA is selected:
Fmax, WNS, TNS, LUT, FF, BRAM, DSP, URAM.

Later architectures must use the same workloads and RX-to-TX boundary.
