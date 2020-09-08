module sram_init(clk, rst, init_done, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
input         clk;
input         rst;
output        init_done;
output [19:0] SRAM_ADDR;
output [15:0] SRAM_DQ;

output        SRAM_CE_N;
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_UB_N;
output        SRAM_LB_N;

reg     [9:0] x;
reg     [9:0] y;
reg     [7:0] red;
reg     [7:0] green;
reg     [7:0] blue;
reg           init_done_r;
reg    [19:0] sram_addr;

wire   [10:0] c;

assign c = x + y;

assign init_done = init_done_r;

assign SRAM_CE_N = init_done_r ? 1'bz : 0;
assign SRAM_OE_N = init_done_r ? 1'bz : 1;
assign SRAM_WE_N = init_done_r ? 1'bz : clk;
assign SRAM_UB_N = init_done_r ? 1'bz : 0;
assign SRAM_LB_N = init_done_r ? 1'bz : 0;
assign SRAM_DQ   = init_done_r ? 16'hzzzz  : {red[4:0], green[5:0], blue[4:0]};
assign SRAM_ADDR = init_done_r ? 20'hzzzzz : sram_addr;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    init_done_r       <= 0;
	 sram_addr         <= 0;
	 x                 <= 0;
	 y                 <= 0;
  end
  else begin
    if (!init_done_r) begin	   
	   red             <=              (c < 80) || (c >= 240 && c < 320) || (c >= 560) ? 6'hff : 6'h00;
      blue            <= (c >= 80  && c < 160) || (c >= 320 && c < 400) || (c >= 560) ? 6'hff : 6'h00;
      green           <= (c >= 160 && c < 240) || (c >= 400 && c < 480) || (c >= 560) ? 6'hff : 6'h00;		
		sram_addr       <= (y * 640 + x);
		
		if (x == 639) begin
		  if (y == 479) begin
		    init_done_r <= 1;
		  end
		  else begin
		    y           <= y + 1;
			 x           <= 0;
		  end
		end
		else begin
		  x             <= x + 1;
		end
	 end
  end
end


endmodule