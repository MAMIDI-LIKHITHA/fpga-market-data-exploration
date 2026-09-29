module baseline_market_pipeline(
  input logic clk,rst_n,input logic in_valid,input logic [127:0] in_event,
  output logic in_ready,output logic out_valid,output logic [31:0] out_sequence,
  output logic [31:0] out_best_bid,out_best_ask,out_spread,
  output logic out_signal,out_risk_accept,output logic [31:0] out_price,out_quantity,
  output logic [63:0] out_latency_cycles
);
  logic ob_valid,ob_ready; logic [31:0] best_bid,best_ask;
  logic [63:0] timestamp,rx_timestamp; logic [31:0] sequence_r,position;
  wire [7:0] msg_type=in_event[127:120]; wire [31:0] seq_num=in_event[119:88];
  wire side=in_event[87]; wire [15:0] order_id=in_event[79:64];
  wire [31:0] price=in_event[63:32]; wire [31:0] quantity=in_event[31:0];
  assign in_ready=ob_ready;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      timestamp<=0; rx_timestamp<=0; sequence_r<=0; position<=0;
      out_valid<=0; out_sequence<=0; out_best_bid<=0; out_best_ask<=0; out_spread<=0;
      out_signal<=0; out_risk_accept<=0; out_price<=0; out_quantity<=0; out_latency_cycles<=0;
    end else begin
      timestamp<=timestamp+1; out_valid<=0;
      if(in_valid && in_ready) begin rx_timestamp<=timestamp; sequence_r<=seq_num; end
      if(ob_valid) begin
        out_valid<=1; out_sequence<=sequence_r; out_best_bid<=best_bid; out_best_ask<=best_ask;
        if(best_ask!=32'hFFFFFFFF && best_bid!=0) begin
          out_spread<=best_ask-best_bid;
          out_signal<=((best_ask-best_bid)<=32'd5);
        end else begin out_spread<=0; out_signal<=0; end
        if(best_ask!=32'hFFFFFFFF && best_bid!=0 && (best_ask-best_bid)<=32'd5) begin
          if(position+1<=32'd100) begin out_risk_accept<=1; out_price<=best_bid; out_quantity<=1; position<=position+1; end
          else begin out_risk_accept<=0; out_price<=best_bid; out_quantity<=0; end
        end else begin out_risk_accept<=0; out_price<=32'hFFFFFFFF; out_quantity<=0; end
        out_latency_cycles<=timestamp-rx_timestamp;
      end
    end
  end

  order_book #(.DEPTH(64)) u_order_book(
    .clk(clk),.rst_n(rst_n),.valid_i(in_valid && in_ready),.msg_type_i(msg_type),
    .side_i(side),.order_id_i(order_id),.price_i(price),.quantity_i(quantity),
    .ready_o(ob_ready),.valid_o(ob_valid),.best_bid_o(best_bid),.best_ask_o(best_ask)
  );
endmodule
