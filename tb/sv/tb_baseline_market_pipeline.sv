module tb_baseline_market_pipeline;
  logic clk=0,rst_n=0,in_valid=0; logic [127:0] in_event=0;
  logic in_ready,out_valid; logic [31:0] out_sequence,out_best_bid,out_best_ask,out_spread,out_price,out_quantity;
  logic out_signal,out_risk_accept; logic [63:0] out_latency_cycles;
  always #5 clk=~clk;

  task automatic send_event(input [7:0] typ,input [31:0] seq,input side,input [15:0] oid,input [31:0] price,input [31:0] qty);
    begin
      @(negedge clk); in_event={typ,seq,side,7'b0,oid,price,qty}; in_valid=1;
      @(negedge clk); while(!in_ready) @(negedge clk); in_valid=0;
    end
  endtask

  always @(posedge clk) if(out_valid)
    $display("OUT seq=%0d bid=%0d ask=%0d spread=%0d signal=%0d risk=%0d price=%0d qty=%0d latency=%0d",
      out_sequence,out_best_bid,out_best_ask,out_spread,out_signal,out_risk_accept,out_price,out_quantity,out_latency_cycles);

  initial begin
    repeat(3) @(posedge clk); rst_n=1;
    send_event(8'd1,1,0,16'd1,10000,10);
    send_event(8'd1,2,1,16'd2,10003,10);
    send_event(8'd2,3,0,16'd1,10000,10);
    send_event(8'd4,4,1,16'd2,10003,5);
    send_event(8'd3,5,1,16'd2,10002,7);
    repeat(5) @(posedge clk); $finish;
  end
endmodule
