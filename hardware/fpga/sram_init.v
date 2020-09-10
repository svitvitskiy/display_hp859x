module sram_init(clk50, rst, enable, init_done, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
input         clk50;
input         rst;
input         enable;
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
reg    [19:0] sram_addr;
reg           init_done_r;

assign SRAM_CE_N = enable ? 0          : 1'bz;
assign SRAM_OE_N = enable ? 1          : 1'bz;
assign SRAM_WE_N = enable ? clk50      : 1'bz;
assign SRAM_UB_N = enable ? 0          : 1'bz;
assign SRAM_LB_N = enable ? 0          : 1'bz;
assign SRAM_DQ   = enable ? 16'h0000   : 16'hzzzz;
assign SRAM_ADDR = enable ? sram_addr  : 20'hzzzzz;

assign init_done = init_done_r;

always @ (posedge clk50 or posedge rst) begin
  if (rst) begin
	 sram_addr         <= 0;
	 x                 <= 0;
	 y                 <= 0;
	 init_done_r       <= 0;
  end
  else begin    
    if (enable) begin
	   sram_addr       <= (y * 640) + x;
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