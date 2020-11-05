module draw_text(clk25, rst, enable, x_from, y_from, code, draw_enable, busy, SRAM_ADDR, SRAM_DQ, SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N);
input         clk25;
input         rst;
input         enable;
input   [9:0] x_from;
input   [9:0] y_from;
input   [6:0] code;
input         draw_enable;
output        busy;

output [19:0] SRAM_ADDR;
output [15:0] SRAM_DQ;
output        SRAM_CE_N;
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_UB_N;
output        SRAM_LB_N;

reg         [1:0] x_r;
reg         [3:0] y_r;
reg         [9:0] x_from_r;
reg         [9:0] y_from_r;
reg         [6:0] code_r;

reg        [15:0] sram_dq_r;
reg         [1:0] state_r;
reg        [19:0] sram_addr_r;
reg               sram_val_r;

assign SRAM_ADDR = enable & sram_val_r ?  sram_addr_r : 20'hzzzzz;
assign SRAM_DQ   = enable & sram_val_r ?    sram_dq_r : 16'hzzzz;
assign SRAM_OE_N = enable & sram_val_r ?            1 : 1'bz;
assign SRAM_WE_N = enable & sram_val_r ?        clk25 : 1'bz;
assign SRAM_CE_N = enable & sram_val_r ?            0 : 1'bz;
assign SRAM_LB_N = enable & sram_val_r ?            0 : 1'bz;
assign SRAM_UB_N = enable & sram_val_r ?            0 : 1'bz;
assign busy      = state_r != 0;


wire [127:0] pixels_w;

char_rom(
    .addr(code_r),
	 .data_out(pixels_w)
);


wire [8:0] xd_r = x_from_r[9:1] + x_r;
wire [9:0] yd_r = y_from_r + y_r;


always @ (posedge clk25 or posedge rst) begin
  if (rst) begin
    state_r           <= 0;
	 sram_addr_r       <= 0;
	 sram_dq_r         <= 0;
	 x_r               <= 0;
	 y_r               <= 0;
	 sram_val_r        <= 0;
  end
  else begin    
	   case(state_r)
		0 : begin
		  x_from_r      <= x_from;
	     y_from_r      <= y_from - 8;
	     code_r        <= code;
		  state_r       <= draw_enable ? 1 : 0;
		  sram_val_r    <= 0;
		end
		1: begin
		  x_r           <= 0;
		  y_r           <= 0;
		  state_r       <= 2;
		end		
		2: begin
		  if (enable) begin
	       sram_addr_r   <= {yd_r, 8'h00} + {yd_r, 6'h00} + xd_r;
		    sram_dq_r     <= {(pixels_w[127 - {y_r, x_r, 1'b1}] ? 8'hff : 8'h00), (pixels_w[127 - {y_r, x_r, 1'b0}] ? 8'hff : 8'h00)};
			 sram_val_r    <= 1;
			 
			 if (x_r == 3'h3) begin
			   if (y_r == 4'hf) begin
				  y_r <= 0;
				  state_r     <= 0;
				end
				else begin
				  y_r <= y_r + 1;
				end
				x_r <= 0;
			 end
			 else begin
			   x_r <= x_r + 1;
			 end
		  end // enable
      end
      default: ;
      endcase
  end // clk
end


endmodule