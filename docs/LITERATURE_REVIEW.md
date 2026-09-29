# Literature Review Framework

This document records representative prior work and the engineering questions motivating this project.

## 1. Low-Latency FPGA Based Financial Data Feed Handler
IEEE FCCM 2011.
Focus: FPGA-based financial feed handling and NASDAQ ITCH processing.
Project use: historical baseline for FPGA feed handling.
Question for this project: how do multiple architecture organizations behave under the same controlled workload?

## 2. High Frequency Trading Acceleration Using FPGAs
IEEE FPL 2011.
Focus: Ethernet/IP/UDP processing, FAST decoding, and FPGA acceleration.
Project use: protocol-processing baseline.
Question: what changes when order-book, strategy, risk, and order generation are included in an end-to-end path?

## 3. Network-Level FPGA Acceleration of Low Latency Market Data Feed Arbitration
IEICE Transactions on Information and Systems, 2015.
Focus: A/B feed arbitration and latency/reliability trade-offs.
Project use: motivation for the dual-feed reliability experiment.
Question: what latency, resource, and verification overhead results when arbitration is integrated into the broader pipeline?

## 4. A Domain-Specific Accelerator for Ultralow Latency Market Data Distribution System
IEEE Transactions on Industrial Informatics.
Focus: FPGA network interface, FAST decoding, pipelined field decoding, and host/PCIe integration.
Project use: highly pipelined protocol-processing reference.
Question: how does specialized processing compare with more general architectures under common workloads?

## 5. Building Low-Latency Order Books with Hybrid Binary-Linear Search Data Structures on FPGAs
IEEE FPL 2023.
Focus: FPGA order-book data structures and hybrid binary-linear search.
Project use: order-book architecture reference.
Question: how does order-book organization interact with upstream parsing and downstream strategy/risk processing?

## 6. Real-Time Order Book Building and Snapshot Generating for High Frequency Trading on FPGA
IEEE ASAP 2024.
Focus: FPGA order-book building, external DRAM address mapping, cache organization, and high message-rate processing.
Project use: memory-system reference.
Question: what are the end-to-end trade-offs when memory architecture is evaluated alongside parser and pipeline architecture?

## 7. An FPGA-Based High-Frequency Trading System for 10 Gigabit Ethernet with a Latency of 433 ns
VLSI-DAT 2022.
Focus: 10GbE, network parsing/packaging, financial protocol processing, order book, and strategy.
Project use: end-to-end architectural reference.
Question: can a controlled multi-architecture benchmark expose latency, tail-latency, resource, timing, reliability, and verification trade-offs?

## Important limitation of literature comparison
Published latency numbers should not be ranked directly unless hardware target, protocol, workload, clock, and measurement boundary are equivalent.

This project therefore emphasizes within-project controlled comparison.

## Research-gap discipline
The project will only claim novelty after deeper literature review. If an apparently new technique has prior art, the claim will be narrowed to the implementation, evaluation methodology, workload, or measured integration result that is actually supported.
