module test_cable(CLOCK_50, GPIO, LEDR, LEDG, KEY);
input         CLOCK_50;
inout  [35:0] GPIO;
output [17:0] LEDR;
output  [7:0] LEDG;
input   [3:0] KEY;

wire        LRFD;
wire        LDAV;
wire [14:0] DATA;
wire        rst;

reg   [7:0] cnt;
reg         prev;

assign GPIO[1]  = LRFD;
assign LDAV     = GPIO[0];

assign DATA[14:0] = {
GPIO[3], GPIO[2], GPIO[5], GPIO[4], GPIO[7],
GPIO[6], GPIO[9], GPIO[8], GPIO[11], GPIO[10],
GPIO[13], GPIO[12], GPIO[15], GPIO[14], 1'b0
};

assign LEDR[0]    = LDAV;
assign LEDR[15:1] = DATA[14:0];
assign LEDG[7:0]  = cnt[7:0];

assign rst        = ~KEY[0];

wire   interest;
assign interest   = DATA[2];

always @ (posedge CLOCK_50 or posedge rst) begin
  if (rst) begin
    cnt    <= 0;
	 prev   <= 0;
  end
  else begin    
    if (interest && (~prev)) begin
	   cnt  <= cnt + 1;  
	 end
    prev   <= interest;
  end  
end


endmodule