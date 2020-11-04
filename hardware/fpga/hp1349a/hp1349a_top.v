module hp1349a_top(clk, rst, draw_en, BUS_LDAV, BUS_LRFD, BUS_DATA, FB_ADDR, FB_DQ, FB_CE_N, FB_OE_N, FB_WE_N, FB_UB_N, FB_LB_N, read_state_r);
input          clk;
input          rst;
input          draw_en;

input          BUS_LDAV;
output         BUS_LRFD;
input   [14:0] BUS_DATA;

output  [19:0] FB_ADDR;
output  [15:0] FB_DQ;
output         FB_CE_N;
output         FB_OE_N;
output         FB_WE_N;
output         FB_UB_N;
output         FB_LB_N;
output   [2:0] read_state_r;

wire     [9:0] draw_x_from;
wire     [9:0] draw_y_from;
wire     [9:0] draw_x_to;
wire     [9:0] draw_y_to;
wire           draw_enable;
wire           draw_busy;

wire           fifo_write_en;
wire    [15:0] fifo_write_data;
wire           fifo_read_en;
wire    [15:0] fifo_read_data;
wire           fifo_empty;
wire           fifo_full;
wire           fifo_almost_empty;
wire           fifo_almost_full;

fifo #(
    .SIZE(4),
	 .WIDTH(16)
) (
    .clk (clk),
    .rst (rst),
    .write_en(fifo_write_en),
    .write_data(fifo_write_data),
    .read_en(fifo_read_en),
    .read_data(fifo_read_data),
    .empty(fifo_empty),
    .full(fifo_full),
    .almost_empty(fifo_almost_empty),
    .almost_full(fifo_almost_full)
);


hp1349a_bus_if(
    .clk             (clk),
	 .rst             (rst),
	 .DATA            (BUS_DATA),
	 .LDAV            (BUS_LDAV),
	 .LRFD            (BUS_LRFD),
	 .fifo_full       (fifo_full),
	 .fifo_write_en   (fifo_write_en),
	 .fifo_write_data (fifo_write_data),
	 .read_state_r    (read_state_r)
);

hp1349a_control(
    .clk             (clk),
	 .rst             (rst),
    .draw_x_from     (draw_x_from),
    .draw_y_from     (draw_y_from),
    .draw_x_to       (draw_x_to),
    .draw_y_to       (draw_y_to),
    .draw_enable     (draw_enable),
    .draw_busy       (draw_busy),
    .fifo_read_en    (fifo_read_en),
	 .fifo_read_data  (fifo_read_data),
	 .fifo_empty      (fifo_empty)
);

draw(
   .clk25            (clk),
	.rst              (rst),
	.enable           (draw_en),
	.x_from           (draw_x_from),
   .y_from           (draw_y_from),
   .x_to             (draw_x_to),
   .y_to             (draw_y_to),
   .draw_enable      (draw_enable),
	.busy             (draw_busy),
	.SRAM_ADDR        (FB_ADDR),
	.SRAM_DQ          (FB_DQ), 
	.SRAM_CE_N        (FB_CE_N),
   .SRAM_OE_N        (FB_OE_N),
   .SRAM_WE_N        (FB_WE_N),
   .SRAM_UB_N        (FB_UB_N),
   .SRAM_LB_N        (FB_LB_N)	
);

endmodule