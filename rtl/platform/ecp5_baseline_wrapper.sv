// Physical FPGA wrapper for the baseline market-data benchmark.
//
// The benchmark core intentionally keeps its 128-bit event interface and
// complete observability for simulation. This wrapper exposes the processing
// interface needed for FPGA implementation while keeping the internal
// latency-cycle counter as a benchmark/debug signal rather than a physical
// package I/O.
//
// The wrapper does not add input or processing pipeline stages: in_event,
// valid/ready, clock/reset, and benchmark result signals are directly wired
// to the baseline core.

module ecp5_baseline_wrapper(
  input  logic        clk,
  input  logic        rst_n,
  input  logic        in_valid,
  input  logic [127:0] in_event,
  output logic        in_ready,

  output logic        out_valid,
  output logic [31:0] out_sequence,
  output logic [31:0] out_best_bid,
  output logic [31:0] out_best_ask,
  output logic [31:0] out_spread,
  output logic        out_signal,
  output logic        out_risk_accept,
  output logic [31:0] out_price,
  output logic [31:0] out_quantity
);

  logic [63:0] out_latency_cycles_unused;

  baseline_market_pipeline u_baseline (
    .clk               (clk),
    .rst_n             (rst_n),
    .in_valid          (in_valid),
    .in_event          (in_event),
    .in_ready          (in_ready),
    .out_valid         (out_valid),
    .out_sequence      (out_sequence),
    .out_best_bid      (out_best_bid),
    .out_best_ask      (out_best_ask),
    .out_spread        (out_spread),
    .out_signal        (out_signal),
    .out_risk_accept   (out_risk_accept),
    .out_price         (out_price),
    .out_quantity      (out_quantity),
    .out_latency_cycles(out_latency_cycles_unused)
  );

endmodule
