module order_book_optimized #(parameter int DEPTH=64)(
  input logic clk,
  input logic rst_n,
  input logic valid_i,
  input logic [7:0] msg_type_i,
  input logic side_i,
  input logic [15:0] order_id_i,
  input logic [31:0] price_i,
  input logic [31:0] quantity_i,
  output logic ready_o,
  output logic valid_o,
  output logic [31:0] best_bid_o,
  output logic [31:0] best_ask_o
);

  localparam logic [7:0] ADD=8'd1;
  localparam logic [7:0] CANCEL=8'd2;
  localparam logic [7:0] MODIFY=8'd3;
  localparam logic [7:0] TRADE=8'd4;

  logic active[0:DEPTH-1];
  logic side_mem[0:DEPTH-1];
  logic [31:0] price_mem[0:DEPTH-1];
  logic [31:0] qty_mem[0:DEPTH-1];

  /*
   * Phase 4B:
   * Balanced reduction tree for best bid / best ask.
   *
   * The baseline scans all 64 entries in one linear always_comb loop.
   * This implementation reduces candidates pairwise:
   *
   *   64 -> 32 -> 16 -> 8 -> 4 -> 2 -> 1
   *
   * giving approximately log2(64) = 6 comparison levels.
   */

  logic [31:0] bid_stage0 [0:63];
  logic [31:0] bid_stage1 [0:31];
  logic [31:0] bid_stage2 [0:15];
  logic [31:0] bid_stage3 [0:7];
  logic [31:0] bid_stage4 [0:3];
  logic [31:0] bid_stage5 [0:1];

  logic [31:0] ask_stage0 [0:63];
  logic [31:0] ask_stage1 [0:31];
  logic [31:0] ask_stage2 [0:15];
  logic [31:0] ask_stage3 [0:7];
  logic [31:0] ask_stage4 [0:3];
  logic [31:0] ask_stage5 [0:1];

  integer i;

  assign ready_o = 1'b1;

  always_comb begin
    for (i=0; i<64; i=i+1) begin
      if (active[i] && !side_mem[i])
        bid_stage0[i] = price_mem[i];
      else
        bid_stage0[i] = 32'd0;

      if (active[i] && side_mem[i])
        ask_stage0[i] = price_mem[i];
      else
        ask_stage0[i] = 32'hFFFFFFFF;
    end

    for (i=0; i<32; i=i+1) begin
      if (bid_stage0[2*i] >= bid_stage0[2*i+1])
        bid_stage1[i] = bid_stage0[2*i];
      else
        bid_stage1[i] = bid_stage0[2*i+1];

      if (ask_stage0[2*i] <= ask_stage0[2*i+1])
        ask_stage1[i] = ask_stage0[2*i];
      else
        ask_stage1[i] = ask_stage0[2*i+1];
    end

    for (i=0; i<16; i=i+1) begin
      if (bid_stage1[2*i] >= bid_stage1[2*i+1])
        bid_stage2[i] = bid_stage1[2*i];
      else
        bid_stage2[i] = bid_stage1[2*i+1];

      if (ask_stage1[2*i] <= ask_stage1[2*i+1])
        ask_stage2[i] = ask_stage1[2*i];
      else
        ask_stage2[i] = ask_stage1[2*i+1];
    end

    for (i=0; i<8; i=i+1) begin
      if (bid_stage2[2*i] >= bid_stage2[2*i+1])
        bid_stage3[i] = bid_stage2[2*i];
      else
        bid_stage3[i] = bid_stage2[2*i+1];

      if (ask_stage2[2*i] <= ask_stage2[2*i+1])
        ask_stage3[i] = ask_stage2[2*i];
      else
        ask_stage3[i] = ask_stage2[2*i+1];
    end

    for (i=0; i<4; i=i+1) begin
      if (bid_stage3[2*i] >= bid_stage3[2*i+1])
        bid_stage4[i] = bid_stage3[2*i];
      else
        bid_stage4[i] = bid_stage3[2*i+1];

      if (ask_stage3[2*i] <= ask_stage3[2*i+1])
        ask_stage4[i] = ask_stage3[2*i];
      else
        ask_stage4[i] = ask_stage3[2*i+1];
    end

    for (i=0; i<2; i=i+1) begin
      if (bid_stage4[2*i] >= bid_stage4[2*i+1])
        bid_stage5[i] = bid_stage4[2*i];
      else
        bid_stage5[i] = bid_stage4[2*i+1];

      if (ask_stage4[2*i] <= ask_stage4[2*i+1])
        ask_stage5[i] = ask_stage4[2*i];
      else
        ask_stage5[i] = ask_stage4[2*i+1];
    end

    if (bid_stage5[0] >= bid_stage5[1])
      best_bid_o = bid_stage5[0];
    else
      best_bid_o = bid_stage5[1];

    if (ask_stage5[0] <= ask_stage5[1])
      best_ask_o = ask_stage5[0];
    else
      best_ask_o = ask_stage5[1];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_o <= 1'b0;
      for (i=0; i<64; i=i+1) begin
        active[i] <= 1'b0;
        side_mem[i] <= 1'b0;
        price_mem[i] <= 32'd0;
        qty_mem[i] <= 32'd0;
      end
    end else begin
      valid_o <= 1'b0;

      if (valid_i && order_id_i < DEPTH) begin
        case (msg_type_i)
          ADD: begin
            active[order_id_i] <= 1'b1;
            side_mem[order_id_i] <= side_i;
            price_mem[order_id_i] <= price_i;
            qty_mem[order_id_i] <= quantity_i;
          end

          CANCEL: begin
            active[order_id_i] <= 1'b0;
            qty_mem[order_id_i] <= 32'd0;
          end

          MODIFY: begin
            active[order_id_i] <= 1'b1;
            side_mem[order_id_i] <= side_i;
            price_mem[order_id_i] <= price_i;
            qty_mem[order_id_i] <= quantity_i;
          end

          TRADE: begin
            if (active[order_id_i]) begin
              if (quantity_i >= qty_mem[order_id_i]) begin
                active[order_id_i] <= 1'b0;
                qty_mem[order_id_i] <= 32'd0;
              end else begin
                qty_mem[order_id_i] <= qty_mem[order_id_i] - quantity_i;
              end
            end
          end

          default: begin
          end
        endcase

        valid_o <= 1'b1;
      end
    end
  end

endmodule
