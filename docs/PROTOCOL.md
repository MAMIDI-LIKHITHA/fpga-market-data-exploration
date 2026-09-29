# Phase 1 Protocol Specification

This is a research abstraction for deterministic FPGA market-data experiments. It is not a proprietary exchange protocol.

## 128-bit event format

| Bits | Field | Width |
|---|---|---:|
| 127:120 | type | 8 |
| 119:88 | sequence | 32 |
| 87 | side | 1 |
| 86:80 | reserved | 7 |
| 79:64 | order_id | 16 |
| 63:32 | price | 32 |
| 31:0 | quantity | 32 |

Message types: 1=ADD, 2=CANCEL, 3=MODIFY, 4=TRADE.

Side: 0=BUY, 1=SELL.

ADD inserts a new active order. CANCEL removes an active order. MODIFY replaces side, price and quantity of an active order. TRADE reduces the active quantity; an order is removed when quantity reaches zero.

Best bid is the maximum active BUY price. Best ask is the minimum active SELL price.

## Synthetic strategy and risk

A signal is asserted when both sides exist and best_ask - best_bid <= SPREAD_THRESHOLD.

The candidate action is a BUY at best_bid with MIN_ORDER_QTY. The risk gate accepts it while position + quantity <= MAX_POSITION.

These rules are deliberately synthetic. The research contribution is architectural measurement, not trading alpha.

## JSONL software format

Each input event is one JSON object per line:

{"type":"ADD","sequence":1,"side":"BUY","order_id":100,"price":10000,"quantity":10}

Python is the functional reference. Later SystemVerilog RTL will consume equivalent fields and be compared against the golden outputs.

## Reliability experiments

Separate workloads may inject sequence gaps, duplicates, or out-of-order sequence numbers. Clean functional vectors remain free of these mutations.

## Reproducibility

Every workload records its PRNG seed and configuration. Same seed + same configuration must produce the same event stream.
