module tb_baseline_golden;
  localparam int N = 8;
  logic clk=0, rst_n=0, in_valid=0;
  logic [127:0] in_event=0;
  logic in_ready,out_valid;
  logic [31:0] out_sequence,out_best_bid,out_best_ask,out_spread,out_price,out_quantity;
  logic out_signal,out_risk_accept;
  logic [63:0] out_latency_cycles;
  integer failures=0, received=0;

  logic [127:0] events[0:N-1];
  logic [255:0] expected[0:N-1];

  always #5 clk=~clk;

  function automatic [255:0] pack_expected(
    input [31:0] seq,bid,ask,spread,position,price,qty,
    input signal,risk
  );
    pack_expected={seq,bid,ask,spread,position,price,qty,signal,risk,30'b0};
  endfunction

  task automatic send_event(input [127:0] word);
    begin
      @(negedge clk);
      in_event=word; in_valid=1'b1;
      @(negedge clk);
      while(!in_ready) @(negedge clk);
      in_valid=1'b0;
    end
  endtask

  task automatic check_output(input [255:0] exp);
    reg [31:0] ebid,eask,espread,eprice,eqty,epos,eseq;
    reg esignal,erisk;
    begin
      @(posedge clk);
      while(!out_valid) @(posedge clk);
      eseq=exp[255:224]; ebid=exp[223:192]; eask=exp[191:160]; espread=exp[159:128];
      epos=exp[127:96]; eprice=exp[95:64]; eqty=exp[63:32]; esignal=exp[31]; erisk=exp[30];
      if(out_sequence!==eseq || out_best_bid!==ebid || out_best_ask!==eask ||
         out_spread!==espread || out_signal!==esignal || out_risk_accept!==erisk ||
         out_price!==eprice || out_quantity!==eqty) begin
        $display("FAIL vector %0d",received);
        $display("  got seq=%0d bid=%h ask=%h spread=%h pos(not exported) signal=%0d risk=%0d price=%h qty=%h",
          out_sequence,out_best_bid,out_best_ask,out_spread,out_signal,out_risk_accept,out_price,out_quantity);
        $display("  exp seq=%0d bid=%h ask=%h spread=%h signal=%0d risk=%0d price=%h qty=%h",
          eseq,ebid,eask,espread,esignal,erisk,eprice,eqty);
        failures=failures+1;
      end else $display("PASS vector %0d latency=%0d cycles",received,out_latency_cycles);
      received=received+1;
    end
  endtask

  initial begin
    // 1 ADD BUY 10000 -> no ask
    events[0]={8'd1,32'd1,1'b0,7'b0,16'd1,32'd10000,32'd10};
    expected[0]=pack_expected(1,10000,32'hFFFFFFFF,32'h0,0,32'hFFFFFFFF,0,0,0);
    // 2 ADD SELL 10003 -> spread 3, signal/risk accepted
    events[1]={8'd1,32'd2,1'b1,7'b0,16'd2,32'd10003,32'd10};
    expected[1]=pack_expected(2,10000,10003,3,1,10000,1,1,1);
    // 3 MODIFY SELL to 10008 -> spread 8, no signal
    events[2]={8'd3,32'd3,1'b1,7'b0,16'd2,32'd10008,32'd10};
    expected[2]=pack_expected(3,10000,10008,8,1,32'hFFFFFFFF,0,0,0);
    // 4 ADD SELL 10005 -> spread 5, signal/risk accepted
    events[3]={8'd1,32'd4,1'b1,7'b0,16'd3,32'd10005,32'd2};
    expected[3]=pack_expected(4,10000,10005,5,2,10000,1,1,1);
    // 5 TRADE order 3 by 1 -> remains at 10005
    events[4]={8'd4,32'd5,1'b1,7'b0,16'd3,32'd0,32'd1};
    expected[4]=pack_expected(5,10000,10005,5,3,10000,1,1,1);
    // 6 CANCEL order 1 -> no bid, no signal
    events[5]={8'd2,32'd6,1'b0,7'b0,16'd1,32'd0,32'd0};
    expected[5]=pack_expected(6,0,10005,0,3,32'hFFFFFFFF,0,0,0);
    // 7 ADD BUY 10002 -> spread 3, signal/risk accepted
    events[6]={8'd1,32'd7,1'b0,7'b0,16'd4,32'd10002,32'd5};
    expected[6]=pack_expected(7,10002,10005,3,4,10002,1,1,1);
    // 8 CANCEL order 2 -> spread remains 3
    events[7]={8'd2,32'd8,1'b1,7'b0,16'd2,32'd0,32'd0};
    expected[7]=pack_expected(8,10002,10005,3,5,10002,1,1,1);

    repeat(3) @(posedge clk);
    rst_n=1;
    for(integer k=0;k<N;k=k+1) begin
      fork
        send_event(events[k]);
        check_output(expected[k]);
      join
    end
    repeat(2) @(posedge clk);
    if(failures==0) $display("GOLDEN SMOKE TEST PASSED: %0d vectors",received);
    else $display("GOLDEN SMOKE TEST FAILED: %0d failures",failures);
    $finish;
  end

  baseline_market_pipeline dut(
    .clk(clk),.rst_n(rst_n),.in_valid(in_valid),.in_event(in_event),.in_ready(in_ready),
    .out_valid(out_valid),.out_sequence(out_sequence),.out_best_bid(out_best_bid),
    .out_best_ask(out_best_ask),.out_spread(out_spread),.out_signal(out_signal),
    .out_risk_accept(out_risk_accept),.out_price(out_price),.out_quantity(out_quantity),
    .out_latency_cycles(out_latency_cycles)
  );
endmodule
