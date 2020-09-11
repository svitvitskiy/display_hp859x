module fifo(clk, rst, write_en, write_data, read_en, read_data, empty, full, almost_empty, almost_full);
input                     clk;
input                     rst;
input                     write_en;
input  [WIDTH-1:0]        write_data;
input                     read_en;
output [WIDTH-1:0]        read_data;
output                    empty;
output                    full;
output                    almost_empty;
output                    almost_full;

parameter SIZE = 4;
parameter WIDTH = 8;

reg       [WIDTH-1:0]   storage_r [SIZE-1:0];
reg  [$clog2(SIZE)-1:0] read_ptr_r;
reg  [$clog2(SIZE)-1:0] write_ptr_r;
reg                     reading_r;
reg                     full_r;
reg                     empty_r;
reg                     almost_full_r;
reg                     almost_empty_r;
reg       [WIDTH-1:0]   data_r;

assign empty        = empty_r;
assign full         = full_r;
assign almost_full  = almost_full_r;
assign almost_empty = almost_empty_r;

assign read_data    = reading_r ? data_r : {WIDTH{1'bz}};

always @ (negedge clk or posedge rst) begin
  if (rst) begin
    read_ptr_r               <= 0;
	 write_ptr_r              <= 0;
	 data_r                   <= 0;
	 full_r                   <= 0;
	 empty_r                  <= 1;
	 almost_full_r            <= 0;
	 almost_empty_r           <= 1;
	 reading_r                <= 0;
  end
  else begin
    reg  [$clog2(SIZE)-1:0] read_ptr_1_w;
    reg  [$clog2(SIZE)-1:0] write_ptr_1_w;
    reg  [$clog2(SIZE)-1:0] read_ptr_2_w;
    reg  [$clog2(SIZE)-1:0] write_ptr_2_w;

    if (write_en && !full_r) begin
	   storage_r[write_ptr_r] <= write_data;
		empty_r                <= 0;
		write_ptr_r             = write_ptr_r + 1;
		write_ptr_1_w           = write_ptr_r + 1;
		read_ptr_2_w            = read_ptr_r + 2;
		
		if (write_ptr_1_w == read_ptr_r) begin
		  almost_full_r        <= 1;
		end
		if (write_ptr_r == read_ptr_r) begin
		  full_r               <= 1;
		end
		if (read_ptr_2_w == write_ptr_r) begin
		  almost_empty_r       <= 0;
		end
	 end else if (read_en && !empty_r) begin
	   reading_r              <= 1;
	   data_r                 <= storage_r[read_ptr_r];
		full_r                 <= 0;
		read_ptr_r              = read_ptr_r + 1;
		read_ptr_1_w            = read_ptr_r + 1;
		write_ptr_2_w           = write_ptr_r + 2;
		if (read_ptr_r == write_ptr_r) begin
		  empty_r              <= 1;
		end
		if (read_ptr_1_w == write_ptr_r) begin
		  almost_empty_r       <= 1;
		end
		if (write_ptr_2_w == read_ptr_r) begin
		  almost_full_r        <= 0;
		end
	 end
	 else begin
	   reading_r              <= 0;		
	 end
  end
end

endmodule