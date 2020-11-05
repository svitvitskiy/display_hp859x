module vga(clk, rst, x_out, y_out, fc_out, fb_en_out, draw_en_out, r_in, g_in, b_in, VGA_CLK, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS);
input        clk;
input        rst;
output [9:0] x_out;
output [9:0] y_out;
output [5:0] fc_out;
output       fb_en_out; 
output       draw_en_out;
input  [5:0] r_in;
input  [5:0] g_in;
input  [5:0] b_in;
output       VGA_CLK;
output [7:0] VGA_R;
output [7:0] VGA_G;
output [7:0] VGA_B;
output       VGA_HS;
output       VGA_VS;

reg  [9:0]  r_x;
reg  [9:0]  r_y;
reg  [5:0]  r_fc;
reg         r_hsync;
reg         r_vsync;
reg         r_hden;
reg         r_vden;
wire        w_den;

assign VGA_CLK     = clk;
assign x_out       = r_x;
assign y_out       = r_y;
assign VGA_R       = w_den ? {r_in, 2'b00} : 0;
assign VGA_G       = w_den ? {g_in, 2'b00} : 0;
assign VGA_B       = w_den ? {b_in, 2'b00} : 0;
assign VGA_HS      = ~r_hsync;
assign VGA_VS      = ~r_vsync;
assign w_den       = r_hden & r_vden;
assign fb_en_out   = w_den;
assign draw_en_out = ~r_vden;
assign fc_out      = r_fc;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
	 r_x              <= 0;
	 r_y              <= 0;
	 r_vsync          <= 0;
	 r_hsync          <= 0;
	 r_hden           <= 0;
	 r_vden           <= 0;
	 r_fc             <= 0;
  end
  else begin
    case (r_x)
      799: r_hden    <= 1;
      639: r_hden    <= 0;
      655: r_hsync   <= 1;
      751: r_hsync   <= 0;
      default: ;
    endcase
    case (r_y)
      524: r_vden    <= 1;
      480: r_vden    <= 0;
      490: r_vsync   <= 1;
      492: r_vsync <= 0;
      default: ;	   
    endcase
    if (r_x == 799) begin
      if (r_y == 524) begin
        r_x        <= 0;
        r_y        <= 0;
		  r_fc       <= r_fc + 1;
      end
      else begin
        r_x        <= 0;
        r_y        <= r_y + 1;
      end
    end
    else begin
      r_x          <= r_x + 1;
    end
  end
end


endmodule