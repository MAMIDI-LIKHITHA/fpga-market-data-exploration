package market_event_pkg;
  localparam logic [7:0] MSG_ADD=8'd1, MSG_CANCEL=8'd2, MSG_MODIFY=8'd3, MSG_TRADE=8'd4;
  localparam int SPREAD_THRESHOLD=5, MIN_ORDER_QTY=1, MAX_POSITION=100;
  typedef struct packed {
    logic [7:0] msg_type; logic [31:0] seq_num; logic side; logic [6:0] reserved;
    logic [15:0] order_id; logic [31:0] price; logic [31:0] quantity;
  } market_event_t;
endpackage
