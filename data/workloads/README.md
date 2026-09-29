# Workload Data

Phase 1 uses small deterministic JSONL vectors.

Generate an input workload:

python scripts/traffic_generator.py --count 100 --seed 20260929 --mode mixed --output data/workloads/mixed_100.jsonl

Generate input plus golden reference:

python scripts/generate_golden_vectors.py --count 100 --seed 20260929 --mode mixed

Workload classes:
- sparse: lower event activity
- sustained: continuous activity
- burst: higher update density
- mixed: initial functional-verification workload

Keep reliability mutations separate from clean correctness vectors. Record seed, generator parameters, RTL revision, FPGA target, clock constraint, and measurement boundary for each experiment.
