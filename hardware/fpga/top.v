module top(GPIO, LEDG, LEDR, CLOCK_50, SMA_CLKOUT, KEY, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
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


wire         rst;
wire   [5:0] red;
wire   [5:0] green;
wire   [5:0] blue;
wire   [9:0] x;
wire   [8:0] y;

wire         init_done;
reg          cnt;

VGG644803(
   .clk       (clk0),
	.rst       (rst),
   .red       (red),
	.green     (green),
	.blue      (blue),
	.x         (x),
	.y         (y),
	.PIN_CLK   (GPIO[0]),
	.PIN_HSYNC (GPIO[1]),
	.PIN_VSYNC (GPIO[2]),
	.PIN_RED   (GPIO[8:3]),
	.PIN_GREEN (GPIO[14:9]),
	.PIN_BLUE  (GPIO[20:15]),
	.PIN_DEN   (GPIO[21]),
	.PIN_REV   (GPIO[22]),
	.PIN_DISP  (GPIO[23])
);

framebuffer(
   .clk       (clk0),
	.rst       (rst),
	.init_done (init_done),
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
   .clk       (clk0),
	.rst       (rst),
	.init_done (init_done),
	.SRAM_ADDR (SRAM_ADDR),
	.SRAM_DQ   (SRAM_DQ), 
	.SRAM_CE_N (SRAM_CE_N),
   .SRAM_OE_N (SRAM_OE_N),
   .SRAM_WE_N (SRAM_WE_N),
   .SRAM_UB_N (SRAM_UB_N),
   .SRAM_LB_N (SRAM_LB_N)
);

wire   clk0, clk1;

assign rst         = ~KEY[0];
assign clk0        = cnt;

assign LEDG[0]     = rst;
assign LEDG[1]     = init_done;
assign LEDG[7:2]   = 0;
assign LEDR        = 0;
assign SMA_CLKOUT  = clk0;

always @ (posedge CLOCK_50 or posedge rst) begin
  if (rst) begin
    cnt       <= 0;
	 //init_done <= 1;
  end
  else begin
    cnt       <= ~cnt;
  end
end

endmodule