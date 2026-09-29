module tb_baseline_golden_icarus;

  localparam int N = 1000;
  localparam int TIMEOUT_CYCLES = 100;

  logic clk = 0;
  logic rst_n = 0;
  logic in_valid = 0;
  logic [127:0] in_event = 0;

  logic in_ready;
  logic out_valid;

  logic [31:0] out_sequence;
  logic [31:0] out_best_bid;
  logic [31:0] out_best_ask;
  logic [31:0] out_spread;
  logic [31:0] out_price;
  logic [31:0] out_quantity;
  logic out_signal;
  logic out_risk_accept;
  logic [63:0] out_latency_cycles;

  integer failures = 0;
  integer received = 0;
  integer k;

  logic [127:0] events [0:N-1];
  logic [255:0] expected [0:N-1];

  always #5 clk = ~clk;

  task automatic send_event(input [127:0] word, output bit success);
    integer wait_cycles;
    begin
      success = 1'b1;
      wait_cycles = 0;

      @(negedge clk);
      in_event = word;
      in_valid = 1'b1;

      @(posedge clk);

      while (!in_ready) begin
        @(posedge clk);
        wait_cycles = wait_cycles + 1;
        if (wait_cycles >= TIMEOUT_CYCLES) begin
          $display("TIMEOUT waiting for in_ready at vector %0d", received);
          failures = failures + 1;
          success = 1'b0;
          @(negedge clk);
          in_valid = 1'b0;
          return;
        end
      end

      @(negedge clk);
      in_valid = 1'b0;
    end
  endtask

  task automatic check_output(input [255:0] exp, output bit success);
    reg [31:0] eseq;
    reg [31:0] ebid;
    reg [31:0] eask;
    reg [31:0] espread;
    reg [31:0] epos;
    reg [31:0] eprice;
    reg [31:0] eqty;
    reg esignal;
    reg erisk;
    integer wait_cycles;

    begin
      success = 1'b1;
      wait_cycles = 0;

      @(posedge clk);

      while (!out_valid) begin
        @(posedge clk);
        wait_cycles = wait_cycles + 1;
        if (wait_cycles >= TIMEOUT_CYCLES) begin
          $display("TIMEOUT waiting for out_valid at vector %0d", received);
          failures = failures + 1;
          success = 1'b0;
          return;
        end
      end

      eseq    = exp[255:224];
      ebid    = exp[223:192];
      eask    = exp[191:160];
      espread = exp[159:128];
      epos    = exp[127:96];
      eprice  = exp[95:64];
      eqty    = exp[63:32];
      esignal = exp[31];
      erisk   = exp[30];

      if (out_sequence !== eseq ||
          out_best_bid !== ebid ||
          out_best_ask !== eask ||
          out_spread !== espread ||
          out_signal !== esignal ||
          out_risk_accept !== erisk ||
          out_price !== eprice ||
          out_quantity !== eqty) begin

        $display("FAIL vector %0d", received);

        $display(
          "  GOT seq=%0d bid=%h ask=%h spread=%h signal=%0d risk=%0d price=%h qty=%h latency=%0d",
          out_sequence,
          out_best_bid,
          out_best_ask,
          out_spread,
          out_signal,
          out_risk_accept,
          out_price,
          out_quantity,
          out_latency_cycles
        );

        $display(
          "  EXP seq=%0d bid=%0d ask=%0d spread=%0d signal=%0d risk=%0d price=%h qty=%h",
          eseq,
          ebid,
          eask,
          espread,
          esignal,
          erisk,
          eprice,
          eqty
        );

        failures = failures + 1;

      end else begin

        if ((received < 10) || ((received + 1) % 100 == 0))
          $display(
            "PASS vector %0d latency=%0d cycles",
            received,
            out_latency_cycles
          );

      end
    end
  endtask

  initial begin
    bit send_ok;
    bit check_ok;

    $display("==============================================");
    $display("BASELINE MARKET PIPELINE GOLDEN TEST (ICARUS)");
    $display("Vectors: %0d", N);
    $display("Timeout: %0d cycles", TIMEOUT_CYCLES);
    $display("==============================================");

    $readmemh("data/workloads/events.mem", events);
    $readmemh("data/workloads/expected.mem", expected);

    $display("Loaded events.mem");
    $display("Loaded expected.mem");

    repeat (3)
      @(posedge clk);

    rst_n = 1'b1;

    for (k = 0; k < N; k = k + 1) begin
      send_event(events[k], send_ok);

      if (send_ok) begin
        check_output(expected[k], check_ok);
      end

      if (!send_ok || !check_ok) begin
        $display("ABORTING GOLDEN TEST after vector %0d", received);
        k = N;
      end

      received = received + 1;
    end

    repeat (2)
      @(posedge clk);

    $display("");
    $display("==============================================");
    $display("GOLDEN TEST SUMMARY");
    $display("==============================================");
    $display("Vectors checked : %0d", received);
    $display("Failures        : %0d", failures);

    if (failures == 0 && received == N)
      $display("GOLDEN TEST PASSED: %0d/%0d vectors", received, N);
    else
      $display("GOLDEN TEST FAILED: %0d failures", failures);

    $display("==============================================");

    $finish;
  end

  baseline_market_pipeline dut(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .in_event(in_event),
    .in_ready(in_ready),

    .out_valid(out_valid),
    .out_sequence(out_sequence),
    .out_best_bid(out_best_bid),
    .out_best_ask(out_best_ask),
    .out_spread(out_spread),

    .out_signal(out_signal),
    .out_risk_accept(out_risk_accept),
    .out_price(out_price),
    .out_quantity(out_quantity),

    .out_latency_cycles(out_latency_cycles)
  );

endmodule
