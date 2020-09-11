module sram_init(clk50, rst, enable, busy, SRAM_EN, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
input         clk50;
input         rst;
input         enable;
output        busy;

input         SRAM_EN;
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
reg           state;

assign SRAM_CE_N = SRAM_EN ? 0          : 1'bz;
assign SRAM_OE_N = SRAM_EN ? 1          : 1'bz;
assign SRAM_WE_N = SRAM_EN ? clk50      : 1'bz;
assign SRAM_UB_N = SRAM_EN ? 0          : 1'bz;
assign SRAM_LB_N = SRAM_EN ? 0          : 1'bz;
assign SRAM_DQ   = SRAM_EN ? 16'hf000   : 16'hzzzz;
assign SRAM_ADDR = SRAM_EN ? sram_addr  : 20'hzzzzz;
assign busy      = state;

always @ (posedge clk50 or posedge rst) begin
  if (rst) begin
	 sram_addr         <= 0;
	 x                 <= 0;
	 y                 <= 0;
	 state             <= 0;
  end
  else begin
    case (state)
	 0: state <= enable ? 1 : 0;
	 1:
      if (SRAM_EN) begin
        sram_addr       <= (y * 640) + x;
        if (x == 639) begin
          if (y == 479) begin
			   x           <= 0;
				y           <= 0;
            state       <= 0;
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
    endcase
  end  
end


endmodule