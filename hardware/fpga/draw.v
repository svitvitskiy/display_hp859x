module draw(clk50, rst, enable, x_from, y_from, x_to, y_to, draw_en, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
input         clk50;
input         rst;
input         enable;
input   [9:0] x_from;
input   [9:0] y_from;
input   [9:0] x_to;
input   [9:0] y_to;
input         draw_en;

// SRAM iface
output [19:0] SRAM_ADDR;
output [15:0] SRAM_DQ;
output        SRAM_CE_N;
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_UB_N;
output        SRAM_LB_N;

reg         [9:0] x_r;
reg         [9:0] y_r;
reg         [9:0] x_from_r;
reg         [9:0] x_to_r;
reg         [9:0] y_from_r;
reg         [9:0] y_to_r;

reg signed [11:0] dx_r;
reg signed [11:0] dy_r;
reg signed [13:0] err_r, e2;
reg               right_r, down_r;

reg        [15:0] sram_dq_r;
reg         [1:0] state_r;
reg        [19:0] sram_addr_r;

assign SRAM_CE_N = enable ? 0                                 : 1'bz;
assign SRAM_OE_N = enable ? 1                                 : 1'bz;
assign SRAM_WE_N = enable ? clk50                             : 1'bz;
assign SRAM_UB_N = enable ? 0                                 : 1'bz;
assign SRAM_LB_N = enable ? 0                                 : 1'bz;
assign SRAM_DQ   = enable ? sram_dq_r                         : 16'hzzzz;
assign SRAM_ADDR = enable ? sram_addr_r                       : 20'hzzzzz;


always @ (posedge clk50 or posedge rst) begin
  if (rst) begin
    state_r           <= 0;
	 sram_addr_r       <= 0;
	 sram_dq_r         <= 0;
	 x_r               <= 0;
	 y_r               <= 0;
  end
  else begin    
	   case(state_r)
		0 : begin
		  x_from_r      <= x_from;
	     y_from_r      <= y_from;
	     x_to_r        <= x_to;
	     y_to_r        <= y_to;
		  state_r       <= draw_en ? 1 : 0;
		end
		1: begin
		  x_r           <= x_from_r;
		  y_r           <= y_from_r;
		  dx_r           = x_to_r - x_from_r;
	     dy_r           = y_to_r - y_from_r;
		  right_r        = dx_r >= 0;
		  down_r         = dy_r >= 0;
		  dx_r           = (~right_r) ? -dx_r : dx_r;
		  dy_r           = down_r ? -dy_r : dy_r;		  
	     err_r         <= dx_r + dy_r;
		  state_r       <= 2;
		end		
		2: begin
		  if (enable) begin
		    sram_addr_r   <= (y_r*640 + x_r);
		    sram_dq_r     <= 16'hffff;

          if (x_r == x_to_r && y_r == y_to_r) begin
  	         state_r     <= 0;
            x_r         <= 0;
			   y_r         <= 0;
          end
          else begin
		      e2           = (err_r << 1);
		      if (e2 > dy_r) begin
			     err_r     <= err_r + dy_r;
				  x_r       <= x_r + (right_r ? 1 : -1);
			   end
			   else if (e2 < dx_r) begin
  	           err_r     <= err_r + dx_r;
              y_r       <= y_r + (down_r ? 1 : -1);
			   end
          end
		  end // enable
      end
      default: ;
      endcase
  end // clk
end


endmodule