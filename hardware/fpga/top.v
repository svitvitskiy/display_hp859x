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
	.enable    (init_enable),
	.busy      (init_busy),
	.SRAM_EN   (cnt == 1 && !init_done),
	.SRAM_ADDR (SRAM_ADDR),
	.SRAM_DQ   (SRAM_DQ), 
	.SRAM_CE_N (SRAM_CE_N),
   .SRAM_OE_N (SRAM_OE_N),
   .SRAM_WE_N (SRAM_WE_N),
   .SRAM_UB_N (SRAM_UB_N),
   .SRAM_LB_N (SRAM_LB_N)
);

wire        LRFD;
wire        LDAV;
wire        LDAV_SLOW;
wire [14:0] DATA;

assign GPIO[1]  = LRFD;
assign LDAV     = GPIO[0];
assign DATA[14:0] = {
   GPIO[3],  GPIO[2],  GPIO[5],  GPIO[4],  GPIO[7],
   GPIO[6],  GPIO[9],  GPIO[8], GPIO[11], GPIO[10],
  GPIO[13], GPIO[12], GPIO[15], GPIO[14], 1'b0
};


slow_signal #(
    .RATIO(256)
) (
    .clk(CLOCK_50),
    .rst(rst),
	 .src(LDAV),
	 .slow(LDAV_SLOW),
	 .cnt_r(LEDR[17:10])
);

//draw_tester(
//   .clk       (CLOCK_50),
//	.rst       (rst),
//	.restart   (init_enable),
//	.LRFD      (LRFD),
//	.LDAV      (LDAV),
//	.DATA      (DATA)
//);

hp1349a_top (
   .clk       (CLOCK_50),
   .rst       (rst),
   .BUS_LDAV  (LDAV_SLOW),
   .BUS_LRFD  (LRFD),
   .BUS_DATA  (DATA),
   .FB_EN     (cnt == 1 && init_done),
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

assign LEDG[5]     = LDAV_SLOW;
assign LEDG[6]     = LDAV;
assign LEDG[7]     = LRFD;

assign LEDR[9:3]   = 0;

always @ (negedge CLOCK_50 or posedge rst) begin
  if (rst) begin
    cnt       <= 0;	 
  end
  else begin
    cnt       <= ~cnt;
  end
end

reg   [2:0] state;
reg         init_enable;
wire        init_busy;
reg  [15:0] timeout;
wire        init_done;

assign init_done = state == 3;
assign LEDG[4:2] = state;

always @ (posedge CLOCK_50 or posedge rst) begin
  if (rst) begin
    state         <= 0;
	 init_enable   <= 0;
	 timeout       <= 0;
  end
  else begin
    case(state)
	 0: begin
	   init_enable <= 1;
		state       <= 1;
	 end
	 1:
	   state       <= 2; // hold off
	 2: begin
	   init_enable <= 0;
		if (!init_busy)
	     state     <= 3;
    end
	 3: begin
      if (!KEY[1]) begin
		  state     <= 4;
		  timeout   <= 16'hffff;
		end
	 end
    default: begin
	   if (timeout == 0)
		  state     <= 0;
		else
		  timeout   <= timeout - 1;
    end	 
	 endcase
  end
end

endmodule