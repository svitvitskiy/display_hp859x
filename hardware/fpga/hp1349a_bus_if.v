module hp1349a_bus_if(clk, rst, DATA, LDAV, LRFD, fifo_full, fifo_write_en, fifo_write_data, read_state_r);
input         clk;
input         rst;
input  [14:0] DATA;
input         LDAV;
output        LRFD;
input         fifo_full;
output        fifo_write_en;
output [15:0] fifo_write_data;
output  [2:0] read_state_r;

reg           rfd_r;        // request for data
reg     [2:0] read_state_r;

reg           fifo_write_en_r;
reg    [15:0] fifo_write_data_r;

assign LRFD            = ~rfd_r;
assign fifo_write_en   = fifo_write_en_r;
assign fifo_write_data = fifo_write_data_r;

reg    [7:0]   timeout_r;

// Recieve logic
always @ (posedge clk or posedge rst) begin
  if (rst) begin
    rfd_r                 <= 0;
	 read_state_r          <= 0;
	 fifo_write_en_r       <= 0;
	 timeout_r             <= 0;
  end
  else begin
    case (read_state_r)
	 default:
	   if (LDAV) begin
	     rfd_r             <= 1;
		  read_state_r      <= 1;
		  timeout_r         <= 8'b11111111;
	   end
	 1: begin
	   if (timeout_r == 0) begin
		  read_state_r      <= 2;
		  timeout_r         <= 8'b11111111;
		end
		else
		  timeout_r         <= timeout_r - 1;
	 end
	 2:
	   if (!LDAV) begin
		  read_state_r      <= 3;
		  timeout_r         <= 8'b11111111;
	   end
		else begin
		  // Robustness, only wait for a certain time, then punt
		  if (timeout_r == 0) begin
		    read_state_r    <= 3;
		    timeout_r       <= 8'b11111111;
		  end
		  else begin
		    timeout_r       <= timeout_r - 1;
		  end
		end
    3: begin
	   if (timeout_r == 0)
		  read_state_r      <= 4;
		else
		  timeout_r         <= timeout_r - 1;
	 end
	 4: begin
      fifo_write_data_r   <= DATA;
      rfd_r               <= 0;
		read_state_r        <= 5;
	 end	 
	 5:
	   if (!fifo_full) begin
		  fifo_write_en_r   <= 1;
	     read_state_r      <= 6;
	   end
	 6:
	   begin
	     read_state_r      <= 0;
		  fifo_write_en_r   <= 0;
	   end
	 endcase
  end
end


endmodule