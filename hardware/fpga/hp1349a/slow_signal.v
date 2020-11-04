module slow_signal(clk, rst, src, slow, cnt_r);
input   clk;
input   rst;
input   src;
output  slow;
output  [$clog2(RATIO)-1:0] cnt_r;

parameter RATIO = 256;

reg  [$clog2(RATIO)-1:0] cnt_r;
reg                      slow_r;

//00000
//00001
//00010
//00011
//00100
//00101
//00110
//00111
//01000
//01001
//01010
//01011
//01100 <--
//01101 
//01110 <--
//01111 
//10000 
//10001 <--
//10010 
//10011 <--
//10100 
//10101 
//10110 
//10111 
//11000
//11001
//11010
//11011
//11100
//11101
//11110
//11111


assign slow = slow_r;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    cnt_r        <= 0;
	 slow_r       <= 0;
  end
  else begin
    if (src) begin
	   if (cnt_r != {$clog2(RATIO){1'b1}}) begin
		  cnt_r    <= cnt_r + 1;
		end
		// Schmidt trigger
		if (cnt_r >= {1'b1, {$clog2(RATIO)-3{1'b0}}, 2'b1}) begin
		  slow_r   <= 1;
		end
	 end
	 else begin
	   if (cnt_r != {$clog2(RATIO){1'b0}}) begin
		  cnt_r    <= cnt_r - 1;
		end
		// Schmidt trigger
		if (cnt_r <= {1'b0, {$clog2(RATIO)-3{1'b1}}, 2'b0}) begin
		  slow_r   <= 0;
		end
	 end
  end
end

endmodule