module VGG644803(clk50, rst, enable, red, green, blue, x, y, PIN_CLK, PIN_HSYNC, PIN_VSYNC, PIN_RED, PIN_GREEN, PIN_BLUE, PIN_DEN, PIN_REV, PIN_DISP);
// Module interface
input        clk50;     // 50 Mhz clock input
input        rst;       // Active high reset
input        enable;
input  [5:0] red;       // Red signal
input  [5:0] green;     // Green signal
input  [5:0] blue;      // Blue signal
output [9:0] x;         // x coordinate of a pixel
output [8:0] y;         // y coordinate of a pixel
// Matrix interface
output       PIN_CLK;
output       PIN_HSYNC;
output       PIN_VSYNC;
output [5:0] PIN_RED;
output [5:0] PIN_GREEN;
output [5:0] PIN_BLUE;
output       PIN_DEN;
output       PIN_REV;
output       PIN_DISP;


// IMPLEMENTATION //////////////////////////////////////
wire       clk_w;
wire       locked_w;
wire       den_w;
wire       rev_w;
wire       disp_w;

reg  [9:0] cnt_h_r;
reg  [9:0] cnt_v_r;
reg        hsync_r;
reg        vsync_r;
reg        hden_r;
reg        vden_r;

reg  [5:0] red_r;
reg  [5:0] green_r;
reg  [5:0] blue_r;

assign clk_w       = enable;
assign den_w       = hden_r & vden_r;
assign rev_w       = 1;
assign disp_w      = 1;
assign x           = den_w ? cnt_h_r - 16 : 0;
assign y           = den_w ? cnt_v_r - 10 : 0;
assign PIN_CLK     = clk_w;
assign PIN_HSYNC   = ~hsync_r;
assign PIN_VSYNC   = ~vsync_r;

assign PIN_RED     = den_w ? red_r   : 0;
assign PIN_GREEN   = den_w ? green_r : 0;
assign PIN_BLUE    = den_w ? blue_r  : 0;

assign PIN_DEN     = den_w;
assign PIN_REV     = rev_w;
assign PIN_DISP    = disp_w;

always @ (posedge clk50 or posedge rst) begin
  if (rst) begin
    cnt_h_r           <= 0;
    cnt_v_r           <= 0;
	 hsync_r           <= 0;
	 vsync_r           <= 0;
	 hden_r            <= 0;
	 vden_r            <= 0;
  end
  else begin
    if (enable) begin
      case (cnt_h_r)	   
        16:  hden_r   <= 1;
        656: hden_r   <= 0;
        720: hsync_r  <= 1;
        752: hsync_r  <= 0;
        default: ;
      endcase
	 
      case (cnt_v_r)
        10:   vden_r  <= 1;
        490:  vden_r  <= 0;
        506:  vsync_r <= 1;
        509:  vsync_r <= 0;
        default: ;	   
      endcase
	 
      if (cnt_h_r == 799) begin
        cnt_h_r       <= 0;
        if (cnt_v_r == 524) begin
          cnt_v_r     <= 0;
        end
        else begin
          cnt_v_r     <= cnt_v_r + 1;
        end
      end
      else begin
        cnt_h_r       <= cnt_h_r + 1;
      end
	 end
  end
end


always @ (negedge clk50 or posedge rst) begin
  if (rst) begin
	 red_r             <= 6'h00;
	 green_r           <= 6'h00;
	 blue_r            <= 6'h00;
  end
  else begin
    if (enable) begin
      red_r           <= red;
      green_r         <= green;
      blue_r          <= blue;
	 end
  end
end

endmodule