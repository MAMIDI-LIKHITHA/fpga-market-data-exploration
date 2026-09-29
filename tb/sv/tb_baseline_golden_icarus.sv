module tb_baseline_golden_icarus;

  localparam N = 1000;
  localparam TIMEOUT_CYCLES = 100;

  reg clk, rst_n, in_valid;
  reg [127:0] in_event;
  wire in_ready, out_valid;
  wire [31:0] out_sequence, out_best_bid, out_best_ask, out_spread;
  wire [31:0] out_price, out_quantity;
  wire out_signal, out_risk_accept;
  wire [63:0] out_latency_cycles;

  integer failures, received, k;
  reg [127:0] events [0:N-1];
  reg [255:0] expected [0:N-1];
  reg [127:0] current_event;
  reg [255:0] current_expected;
  reg send_ok, check_ok;

  initial begin
    clk=0; rst_n=0; in_valid=0; in_event=0;
    failures=0; received=0; k=0;
  end

  always #5 clk = ~clk;

  task send_event;
    input [127:0] word;
    integer wait_cycles;
    begin
      send_ok = 1'b1;
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
          send_ok = 1'b0;
          @(negedge clk);
          in_valid = 1'b0;
          return;
        end
      end
      @(negedge clk);
      in_valid = 1'b0;
    end
  endtask

  task check_output;
    input [255:0] exp;
    reg [31:0] eseq, ebid, eask, espread, eprice, eqty;
    reg esignal, erisk;
    integer wait_cycles;
    begin
      check_ok = 1'b1;
      wait_cycles = 0;
      @(posedge clk);
      while (!out_valid) begin
        @(posedge clk);
        wait_cycles = wait_cycles + 1;
        if (wait_cycles >= TIMEOUT_CYCLES) begin
          $display("TIMEOUT waiting for out_valid at vector %0d", received);
          failures = failures + 1;
          check_ok = 1'b0;
          return;
        end
      end

      eseq=exp[255:224]; ebid=exp[223:192]; eask=exp[191:160];
      espread=exp[159:128]; eprice=exp[95:64]; eqty=exp[63:32];
      esignal=exp[31]; erisk=exp[30];

      if (out_sequence !== eseq || out_best_bid !== ebid ||
          out_best_ask !== eask || out_spread !== espread ||
          out_signal !== esignal || out_risk_accept !== erisk ||
          out_price !== eprice || out_quantity !== eqty) begin
        $display("FAIL vector %0d", received);
        $display("  GOT seq=%0d bid=%h ask=%h spread=%h signal=%0d risk=%0d price=%h qty=%h latency=%0d",
          out_sequence,out_best_bid,out_best_ask,out_spread,out_signal,
          out_risk_accept,out_price,out_quantity,out_latency_cycles);
        $display("  EXP seq=%0d bid=%h ask=%h spread=%h signal=%0d risk=%0d price=%h qty=%h",
          eseq,ebid,eask,espread,esignal,erisk,eprice,eqty);
        failures = failures + 1;
        check_ok = 1'b0;
      end
      else if ((received < 10) || (((received + 1) % 100) == 0))
        $display("PASS vector %0d latency=%0d cycles", received, out_latency_cycles);
    end
  endtask

  initial begin
    $display("==============================================");
    $display("BASELINE MARKET PIPELINE GOLDEN TEST (ICARUS)");
    $display("Vectors: %0d", N);
    $display("Timeout: %0d cycles", TIMEOUT_CYCLES);
    $display("==============================================");

    $readmemh("data/workloads/events.mem", events);
    $readmemh("data/workloads/expected.mem", expected);
    $display("Loaded events.mem");
    $display("Loaded expected.mem");

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    k=0;
    while (k < N) begin
      current_event = events[k];
      current_expected = expected[k];

      send_event(current_event);

      if (send_ok)
        check_output(current_expected);
      else
        check_ok = 1'b0;

      if (!send_ok || !check_ok) begin
        $display("ABORTING GOLDEN TEST after vector %0d", received);
        k = N;
      end
      else begin
        received = received + 1;
        k = k + 1;
      end
    end

    repeat (2) @(posedge clk);
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
    .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .in_event(in_event),
    .in_ready(in_ready), .out_valid(out_valid),
    .out_sequence(out_sequence), .out_best_bid(out_best_bid),
    .out_best_ask(out_best_ask), .out_spread(out_spread),
    .out_signal(out_signal), .out_risk_accept(out_risk_accept),
    .out_price(out_price), .out_quantity(out_quantity),
    .out_latency_cycles(out_latency_cycles)
  );

endmodule
