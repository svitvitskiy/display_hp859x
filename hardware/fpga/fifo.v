module fifo(clk, rst, write_en, write_data, read_en, read_data, empty, full, almost_empty, almost_full);
input clk;
input rst;
input write_en;
input [WIDTH-1:0]  write_data;
input read_en;
output [WIDTH-1:0]  read_data;
output empty;
output full;
output almost_empty;
output almost_full;

parameter SIZE = 8;
parameter WIDTH = 8;

reg      [WIDTH-1:0] storage [SIZE-1:0];
reg [$clog2(SIZE):0] read_ptr;
reg [$clog2(SIZE):0] write_ptr;
reg                  reading;

assign empty        = read_ptr == write_ptr;
assign full         = read_ptr - write_ptr == 1;
assign almost_full  = read_ptr - write_ptr == 2;
assign almost_empty = write_ptr - read_ptr == 1;

assign read_data    = reading ? storage[read_ptr] : {WIDTH{1'bz}};

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    read_ptr  <= 0;
	 write_ptr <= 0;
  end
  else begin
    if (write_en) begin
	   storage[write_ptr]  <= write_data;
		write_ptr           <= write_ptr + 1;
	 end
	 else if (read_en) begin
	   reading             <= 1;
	 end
	 else if (!read_en && reading) begin
	   reading             <= 0;
		read_ptr            <= read_ptr + 1;
	 end
  end
end

endmodule