module top(GPIO, LEDG, LEDR, CLOCK_50, SMA_CLKOUT, KEY, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N, VGA_CLK, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);
inout  [35:0] GPIO;
output [ 7:0] LEDG;
output [17:0] LEDR;
input         CLOCK_50;
input   [3:0] KEY;
output        SMA_CLKOUT;

output [19:0] SRAM_ADDR;
inout  [15:0] SRAM_DQ;

output        SRAM_CE_N;
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_UB_N;
output        SRAM_LB_N;

output       VGA_CLK;
output       VGA_HS;
output       VGA_VS;
output [7:0] VGA_R;
output [7:0] VGA_G;
output [7:0] VGA_B;

wire         clk25;
wire         locked;
wire         rst;
wire         draw_en;
wire         LRFD;
wire         LDAV;
wire         LDAV_SLOW;
wire  [14:0] DATA;

assign GPIO[1]  = LRFD;
assign LDAV     = GPIO[0];
assign DATA[14:0] = {
   GPIO[3],  GPIO[2],  GPIO[5],  GPIO[4],  GPIO[7],
   GPIO[6],  GPIO[9],  GPIO[8], GPIO[11], GPIO[10],
  GPIO[13], GPIO[12], GPIO[15], GPIO[14], 1'b0
};

clock_25175 (
	.areset (rst),
	.inclk0 (CLOCK_50),
	.c0     (clk25),
	.locked (locked));

display_top (
 .clk         (clk25),
 .rst         (rst),
 .draw_en_out (draw_en),
 .SRAM_ADDR   (SRAM_ADDR),
 .SRAM_DQ     (SRAM_DQ),
 .SRAM_OE_N   (SRAM_OE_N),
 .SRAM_WE_N   (SRAM_WE_N),
 .SRAM_CE_N   (SRAM_CE_N),
 .SRAM_LB_N   (SRAM_LB_N),
 .SRAM_UB_N   (SRAM_UB_N),
 .VGA_CLK     (VGA_CLK),
 .VGA_R       (VGA_R),
 .VGA_G       (VGA_G),
 .VGA_B       (VGA_B),
 .VGA_HS      (VGA_HS),
 .VGA_VS      (VGA_VS));

slow_signal #(
    .RATIO(32)
) (
    .clk(CLOCK_50),
    .rst(rst),
	 .src(LDAV),
	 .slow(LDAV_SLOW),
	 .cnt_r(LEDR[17:10])
);

hp1349a_top (
   .clk       (clk25),
   .rst       (rst),
	.draw_en   (draw_en),
   .BUS_LDAV  (LDAV_SLOW),
   .BUS_LRFD  (LRFD),
   .BUS_DATA  (DATA),
	.FB_ADDR   (SRAM_ADDR),
	.FB_DQ     (SRAM_DQ),
	.FB_CE_N   (SRAM_CE_N),
	.FB_OE_N   (SRAM_OE_N),
	.FB_WE_N   (SRAM_WE_N),
	.FB_UB_N   (SRAM_UB_N),
	.FB_LB_N   (SRAM_LB_N),
	.read_state_r(LEDR[2:0])
);

assign rst         = ~KEY[0];

assign LEDG[0]     = rst;
assign LEDG[1]     = KEY[1];
assign LEDG[2]     = LDAV_SLOW;
assign LEDG[3]     = LDAV;
assign LEDG[4]     = LRFD;

assign LEDG[7:5]   = 9;
assign LEDR[9:3]   = 0;


endmodule