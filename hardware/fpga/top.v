module top(GPIO, LEDG, LEDR, CLOCK_50, SMA_CLKOUT, KEY);
inout  [35:0] GPIO;
output [ 7:0] LEDG;
output [17:0] LEDR;
input         CLOCK_50;
input   [3:0] KEY;
output        SMA_CLKOUT;


wire clk;
wire locked;
wire areset;
wire rst;
wire den;
wire rev;
wire disp;

reg  [9:0] cnt_h;
reg  [9:0] cnt_v;
reg        hsync;
reg        vsync;
reg        hden;
reg        vden;

reg  [5:0] red;
reg  [5:0] green;
reg  [5:0] blue;
reg        cnt;

//clock_25175 (rst, CLOCK_50, clk, locked);

assign LEDG[0]     = locked;
assign LEDG[1]     = rst;
assign LEDG[7:2]   = 0;
assign LEDR        = 0;
assign SMA_CLKOUT  = clk;
assign rst         = ~KEY[0];
assign den         = hden & vden;
assign rev         = 1;
assign disp        = 1;
assign clk         = cnt;

assign GPIO[0]     = clk;
assign GPIO[1]     = ~hsync;
assign GPIO[2]     = ~vsync;
assign GPIO[8:3]   = red[5:0];
assign GPIO[14:9]  = green[5:0];
assign GPIO[20:15] = blue[5:0];
assign GPIO[21]    = den;
assign GPIO[22]    = rev;
assign GPIO[23]    = disp;

always @ (posedge CLOCK_50) begin
  cnt       <= ~cnt;
end

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    cnt_h   <= 0;
    cnt_v   <= 0;
	 hsync   <= 0;
	 vsync   <= 0;
	 hden    <= 0;
	 vden    <= 0;
	 red     <= 6'h00;
	 green   <= 6'h00;
	 blue    <= 6'h00;
  end
  else begin
    case (cnt_h)
	   16:   begin
		  red     <= 6'hff;
	     green   <= 6'h00;
	     blue    <= 6'h00;
		end
		96:   begin
		  red     <= 6'h00;
	     green   <= 6'hff;
	     blue    <= 6'h00;
		end
		176:   begin
		  red     <= 6'h00;
	     green   <= 6'h00;
	     blue    <= 6'hff;
		end
		256:   begin
		  red     <= 6'hff;
	     green   <= 6'h00;
	     blue    <= 6'hff;
		end
		336:   begin
		  red     <= 6'h00;
	     green   <= 6'hff;
	     blue    <= 6'hff;
		end
		416:   begin
		  red     <= 6'hff;
	     green   <= 6'hff;
	     blue    <= 6'h00;
		end
		496:   begin
		  red     <= 6'h00;
	     green   <= 6'h00;
	     blue    <= 6'h00;
		end
		576:   begin
		  red     <= 6'hff;
	     green   <= 6'hff;
	     blue    <= 6'hff;
		end
		default: ;
	 endcase

    case (cnt_h)	   
		16:  hden  <= 1;
		656: hden  <= 0;
		704: hsync <= 1;
		736: hsync <= 0;
      default: ;
	 endcase
	 
	 case (cnt_v)
	   10:   vden <= 1;
		490:  vden <= 0;
		506:  vsync <= 1;
		509:  vsync <= 0;
      default: ;	   
	 endcase
	 
    if (cnt_h == 799) begin
	   cnt_h   <= 0;
		if (cnt_v == 524) begin
		  cnt_v <= 0;
		end
		else begin
	     cnt_v <= cnt_v + 1;
		end
	 end
	 else begin
      cnt_h   <= cnt_h + 1;
	 end
  end
end

endmodule