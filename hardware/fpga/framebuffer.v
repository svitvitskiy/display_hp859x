module framebuffer(clk, rst, init_done, red, green, blue, x, y, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
input        clk;       // 25 Mhz clock input
input        rst;       // Active high reset
input        init_done; // init done ?
output [5:0] red;       // Red signal
output [5:0] green;     // Green signal
output [5:0] blue;      // Blue signal
input  [9:0] x;         // x coordinate of a pixel
input  [8:0] y;         // y coordinate of a pixel

output [19:0] SRAM_ADDR;
input  [15:0] SRAM_DQ;

reg    [25:0] cnt;
reg           do_sram;

output        SRAM_CE_N;
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_UB_N;
output        SRAM_LB_N;

assign        SRAM_CE_N = init_done ? 0 : 1'bz;
assign        SRAM_OE_N = init_done ? 0 : 1'bz;
assign        SRAM_WE_N = init_done ? 1 : 1'bz;
assign        SRAM_UB_N = init_done ? 0 : 1'bz;
assign        SRAM_LB_N = init_done ? 0 : 1'bz;
assign        SRAM_ADDR = init_done ? (y*640 + x) : 20'hzzzzz;

wire    [5:0] red_t;
wire    [5:0] green_t;
wire    [5:0] blue_t;


assign red_t       = init_done ? (             (x < 80) || (x >= 240 && x < 320) || (x >= 560) ? 6'hff : 6'h00) : 6'hzz;
assign green_t     = init_done ? ((x >= 80  && x < 160) || (x >= 320 && x < 400) || (x >= 560) ? 6'hff : 6'h00) : 6'hzz;
assign blue_t      = init_done ? ((x >= 160 && x < 240) || (x >= 400 && x < 480) || (x >= 560) ? 6'hff : 6'h00) : 6'hzz;

assign red         = init_done ? (do_sram ? SRAM_DQ[15:11] : red_t)   : 6'hzz;
assign green       = init_done ? (do_sram ? SRAM_DQ [10:5] : green_t) : 6'hzz;
assign blue        = init_done ? (do_sram ? SRAM_DQ  [4:0] : blue_t)  : 6'hzz;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    cnt       <= 0;
	 do_sram   <= 0;
  end
  else begin
    if (!do_sram) begin
      if (cnt == 26'h3ffffff) begin
	     do_sram <= 1;
	   end
	   else begin
	     cnt     <= cnt + 1;
	   end
	 end
  end
end


endmodule