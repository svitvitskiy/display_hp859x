module draw_tester(clk, rst, restart, LRFD, LDAV, DATA);
input         clk;
input         rst;
input         restart;
input         LRFD;
output        LDAV;
output [14:0] DATA;


reg [4:0]  state;
reg        ldav;
reg [14:0] data;

reg [10:0]  x_from;
reg [10:0]  y_from;
reg [10:0]  x_to;
reg [10:0]  y_to;

reg [31:0]  cnt;

assign LDAV = ldav;
assign DATA = data;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    state       <= 0;
	 ldav        <= 1;
	 data        <= 0;
	 x_from      <= 0;
    y_from      <= 0;
    x_to        <= 500;
    y_to        <= 500;
	 cnt         <= 32'h0003ffff;
  end
  else begin
    case(state)
	 0: state    <= (LRFD ? 0 : 1);
	 1: begin
	   data      <= {4'b0000, x_from};
		ldav      <= 0;
		state     <= 2;
	 end
	 2: state    <= (!LRFD ? 2 : 3);
	 3: begin
	    ldav     <= 1;
		 state    <= 4;
	 end
	 4: state    <= (LRFD ? 4 : 5);
	 5: begin
	   data      <= {4'b0010, y_from};
		ldav      <= 0;
		state     <= 6;
	 end
	 6: state    <= (!LRFD ? 6 : 7);
	 7: begin
	    ldav     <= 1;
		 state    <= 8;
	 end	 
	 ///
	 8: state    <= (LRFD ? 8 : 9);
	 9: begin
	   data      <= {4'b0000, x_to};
		ldav      <= 0;
		state     <= 10;
	 end
	 10: state    <= (!LRFD ? 10 : 11);
	 11: begin
	    ldav     <= 1;
		 state    <= 12;
	 end
	 12: state    <= (LRFD ? 12 : 13);
	 13: begin
	   data      <= {4'b0011, y_to};
		ldav      <= 0;
		state     <= 14;
	 end
	 14: state    <= (!LRFD ? 14 : 15);
	 15: begin
	    ldav     <= 1;
		 state    <= cnt != 0 ? 0 : 16;
		 cnt      <= cnt - 1;
		 x_from   <= x_from + 9;
		 y_from   <= y_from + 13;
		 x_to     <= x_to + 17;
		 y_to     <= y_to + 23;		 
	 end
	 default:
	   if (restart) begin
		  state   <= 0;
		  cnt     <= 32'h0003ffff;
		end
	 endcase    
  end


end


endmodule