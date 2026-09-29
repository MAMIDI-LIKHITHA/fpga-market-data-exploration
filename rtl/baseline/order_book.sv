module order_book #(parameter int DEPTH=64)(
  input logic clk,rst_n,input logic valid_i,
  input logic [7:0] msg_type_i,input logic side_i,input logic [15:0] order_id_i,
  input logic [31:0] price_i,quantity_i,output logic ready_o,valid_o,
  output logic [31:0] best_bid_o,best_ask_o
);
  localparam logic [7:0] ADD=8'd1,CANCEL=8'd2,MODIFY=8'd3,TRADE=8'd4;
  logic active[0:DEPTH-1],side_mem[0:DEPTH-1];
  logic [31:0] price_mem[0:DEPTH-1],qty_mem[0:DEPTH-1];
  integer i,j;
  assign ready_o=1'b1;
  always_comb begin
    best_bid_o=32'd0; best_ask_o=32'hFFFFFFFF;
    for(j=0;j<DEPTH;j=j+1) begin
      if(active[j] && !side_mem[j] && price_mem[j]>best_bid_o) best_bid_o=price_mem[j];
      if(active[j] && side_mem[j] && price_mem[j]<best_ask_o) best_ask_o=price_mem[j];
    end
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      valid_o<=0;
      for(i=0;i<DEPTH;i=i+1) begin active[i]<=0; side_mem[i]<=0; price_mem[i]<=0; qty_mem[i]<=0; end
    end else begin
      valid_o<=0;
      if(valid_i && order_id_i<DEPTH) begin
        case(msg_type_i)
          ADD: begin active[order_id_i]<=1; side_mem[order_id_i]<=side_i; price_mem[order_id_i]<=price_i; qty_mem[order_id_i]<=quantity_i; end
          CANCEL: begin active[order_id_i]<=0; qty_mem[order_id_i]<=0; end
          MODIFY: begin active[order_id_i]<=1; side_mem[order_id_i]<=side_i; price_mem[order_id_i]<=price_i; qty_mem[order_id_i]<=quantity_i; end
          TRADE: if(active[order_id_i]) begin
            if(quantity_i>=qty_mem[order_id_i]) begin active[order_id_i]<=0; qty_mem[order_id_i]<=0; end
            else qty_mem[order_id_i]<=qty_mem[order_id_i]-quantity_i;
          end
          default: begin end
        endcase
        valid_o<=1;
      end
    end
  end
endmodule
