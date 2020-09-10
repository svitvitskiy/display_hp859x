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

wire         init_done;
wire         rst;
wire   [5:0] red;
wire   [5:0] green;
wire   [5:0] blue;
wire   [9:0] x;
wire   [8:0] y;

reg          cnt;

vga(
   .clk50     (CLOCK_50),
	.rst       (rst),
	.enable    (cnt == 0),
   .red       (red),
	.green     (green),
	.blue      (blue),
	.x         (x),
	.y         (y),
   .VGA_CLK   (VGA_CLK),
	.VGA_HS    (VGA_HS),
	.VGA_VS    (VGA_VS),
	.VGA_R     (VGA_R),
	.VGA_G     (VGA_G),
	.VGA_B     (VGA_B)
);

//VGG644803(
//   .clk50     (CLOCK_50),
//	.rst       (rst),
//	.enable    (cnt == 0),
//   .red       (red),
//	.green     (green),
//	.blue      (blue),
//	.x         (x),
//	.y         (y),
//	.PIN_CLK   (GPIO[0]),
//	.PIN_HSYNC (GPIO[1]),
//	.PIN_VSYNC (GPIO[2]),
//	.PIN_RED   (GPIO[8:3]),
//	.PIN_GREEN (GPIO[14:9]),
//	.PIN_BLUE  (GPIO[20:15]),
//	.PIN_DEN   (GPIO[21]),
//	.PIN_REV   (GPIO[22]),
//	.PIN_DISP  (GPIO[23])
//);

framebuffer(
   .clk       (CLOCK_50),
	.rst       (rst),
	.enable    (cnt == 0),
   .red       (red),
	.green     (green),
	.blue      (blue),
	.x         (x),
	.y         (y),
	.SRAM_ADDR (SRAM_ADDR),
	.SRAM_DQ   (SRAM_DQ), 
	.SRAM_CE_N (SRAM_CE_N),
   .SRAM_OE_N (SRAM_OE_N),
   .SRAM_WE_N (SRAM_WE_N),
   .SRAM_UB_N (SRAM_UB_N),
   .SRAM_LB_N (SRAM_LB_N)
);

sram_init (
   .clk50     (CLOCK_50),
	.rst       (rst),
	.enable    (cnt == 1 && !init_done),
	.init_done (init_done),
	.SRAM_ADDR (SRAM_ADDR),
	.SRAM_DQ   (SRAM_DQ), 
	.SRAM_CE_N (SRAM_CE_N),
   .SRAM_OE_N (SRAM_OE_N),
   .SRAM_WE_N (SRAM_WE_N),
   .SRAM_UB_N (SRAM_UB_N),
   .SRAM_LB_N (SRAM_LB_N)
);

draw(
   .clk50     (CLOCK_50),
	.rst       (rst),
	.enable    (cnt == 1 && init_done),
	.x_from    (x_from_r),
   .y_from    (y_from_r),
   .x_to      (x_to_r),
   .y_to      (y_to_r),
   .draw_en   (~KEY[1]),
	.SRAM_ADDR (SRAM_ADDR),
	.SRAM_DQ   (SRAM_DQ), 
	.SRAM_CE_N (SRAM_CE_N),
   .SRAM_OE_N (SRAM_OE_N),
   .SRAM_WE_N (SRAM_WE_N),
   .SRAM_UB_N (SRAM_UB_N),
   .SRAM_LB_N (SRAM_LB_N)	
);

reg  [8:0]  x_from_r;
reg  [7:0]  y_from_r;
reg  [8:0]  x_to_r;
reg  [7:0]  y_to_r;
//
//fifo #(
//    .SIZE(16),
//	 .WIDTH(16)
//  )
//  command_fifo (
//  );

assign rst         = ~KEY[0];

assign LEDG[0]     = rst;
assign LEDG[7:1]   = 0;
assign LEDR        = 0;
//assign SMA_CLKOUT  = clk0;

always @ (negedge CLOCK_50 or posedge rst) begin
  if (rst) begin
    cnt       <= 0;
	 x_from_r  <= 0;
	 y_from_r  <= 0;
	 x_to_r    <= 100;
	 y_to_r    <= 100;
  end
  else begin
    cnt       <= ~cnt;
	 x_from_r  <= x_from_r + 1;
	 y_from_r  <= y_from_r + 2;
	 x_to_r    <= x_to_r + 3;
	 y_to_r    <= y_to_r + 4;
  end
end

endmodule