module sram_init(clk50, rst, enable, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
input         clk50;
input         rst;
input         enable;
output [19:0] SRAM_ADDR;
output [15:0] SRAM_DQ;

output        SRAM_CE_N;
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_UB_N;
output        SRAM_LB_N;

reg    [23:0] cool;
reg           up;
reg     [9:0] x;
reg     [9:0] y;
reg     [7:0] red;
reg     [7:0] green;
reg     [7:0] blue;
reg    [19:0] sram_addr;

wire   [12:0] c;

assign c = x + y + cool[23:20];


assign SRAM_CE_N = enable ? 0                                 : 1'bz;
assign SRAM_OE_N = enable ? 1                                 : 1'bz;
assign SRAM_WE_N = enable ? clk50                             : 1'bz;
assign SRAM_UB_N = enable ? 0                                 : 1'bz;
assign SRAM_LB_N = enable ? 0                                 : 1'bz;
assign SRAM_DQ   = enable ? {red[4:0], green[5:0], blue[4:0]} : 16'hzzzz;
assign SRAM_ADDR = enable ? sram_addr                         : 20'hzzzzz;

always @ (posedge clk50 or posedge rst) begin
  if (rst) begin
	 sram_addr         <= 0;
	 x                 <= 0;
	 y                 <= 0;
	 cool              <= 0;
	 up                <= 1;
  end
  else begin    
    if (enable) begin
	   red             <=              (c < 80) || (c >= 240 && c < 320) || (c >= 560) ? 6'hff : 6'h00;
      blue            <= (c >= 80  && c < 160) || (c >= 320 && c < 400) || (c >= 560) ? 6'hff : 6'h00;
      green           <= (c >= 160 && c < 240) || (c >= 400 && c < 480) || (c >= 560) ? 6'hff : 6'h00;		
		sram_addr       <= (y * 640 + x);
		
		if (x == 639) begin
		  if (y == 479) begin
		    y           <= 0;
			 x           <= 0;
		  end
		  else begin
		    y           <= y + 1;
			 x           <= 0;
		  end
		end
		else begin
		  x             <= x + 1;
		end
		//cool            <= cool + 1;
		if (cool == 24'hffffff) begin
		  up            <= 0;
		  cool          <= 24'hfffffe;
		end
		else if (cool == 0) begin
        up            <= 1;
		  cool          <= 1;
		end
		else begin
		  cool          <= cool + (up ? 1 : -1);
		end
	 end
  end
end


endmodule