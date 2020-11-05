module hp1349a_control(clk, rst, draw_x_from, draw_y_from, draw_x_to, draw_y_to, draw_char_code, draw_enable, draw_text_enable, draw_busy, fifo_read_en, fifo_read_data, fifo_empty);
input         clk;
input         rst;
output  [9:0] draw_x_from;
output  [9:0] draw_y_from;
output  [9:0] draw_x_to;
output  [9:0] draw_y_to;
output  [6:0] draw_char_code;
output        draw_enable;
output        draw_text_enable;
input         draw_busy;
output        fifo_read_en;
input  [15:0] fifo_read_data;
input         fifo_empty;

reg     [2:0] state_r;
reg           fifo_read_r;
reg    [14:0] command_r;
reg    [10:0] cur_x_r;
reg    [10:0] cur_y_r;
reg    [10:0] prev_x_r;
reg    [10:0] prev_y_r;
reg    [10:0] inc_x_r;
reg    [10:0] next_x_r;
reg           pc_r;

reg     [9:0] x_from_r;
reg     [9:0] y_from_r;
reg     [9:0] x_to_r;
reg     [9:0] y_to_r;
reg     [6:0] char_code_r;
reg           draw_en_r;
reg           draw_text_en_r;


assign fifo_read_en = fifo_read_r;

assign draw_x_from  = draw_en_r ? x_from_r : 10'hzzz;
assign draw_y_from  = draw_en_r ? y_from_r : 10'hzzz;
assign draw_x_to    = draw_en_r ? x_to_r   : 10'hzzz;
assign draw_y_to    = draw_en_r ? y_to_r   : 10'hzzz;
assign draw_enable  = draw_en_r;
assign draw_text_enable = draw_text_en_r;
assign draw_char_code = char_code_r;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    state_r            <= 0;
	 fifo_read_r        <= 0;
	 draw_en_r          <= 0;
	 draw_text_en_r     <= 0;
	 cur_x_r            <= 0;
    cur_y_r            <= 0;
    prev_x_r           <= 0;
	 next_x_r           <= 0;
    prev_y_r           <= 0;
	 pc_r               <= 0;
	 inc_x_r            <= 1;
  end
  else begin
    case (state_r)
	 default:
	   if (!fifo_empty) begin
		  fifo_read_r    <= 1;
		  state_r        <= 1;
		end
	 1:
	   begin
	     fifo_read_r    <= 0;
		  command_r      <= fifo_read_data;
		  state_r        <= 2;
		end
	 2:
	   begin
		  // command decoding logic
		  if (command_r[14:13] == 2'b00) begin
		    // plot command
			 if (command_r[12] == 0) begin
			   cur_x_r    <= command_r[10:0];
				next_x_r   <= command_r[10:0];
				pc_r       <= command_r[11];
				state_r    <= 0;
			 end
			 else begin
			   cur_y_r    <= command_r[10:0];
				pc_r        = command_r[11];
				state_r    <= pc_r ? 3 : 7;
			 end
		  end
		  else if (command_r[14:13] == 2'b01) begin
		    // graph command
			 if (command_r[12] == 0) begin
			   inc_x_r    <= command_r[10:0];
				pc_r       <= command_r[11];
				state_r    <= 0;
			 end
			 else begin
			   cur_y_r    <= command_r[10:0];
				cur_x_r    <= next_x_r;
				next_x_r   <= next_x_r + inc_x_r;
				pc_r        = command_r[11];
				state_r    <= pc_r ? 3 : 7;
			 end
		  end
		  else if (command_r[14:13] == 2'b10) begin
		    // text command
			 char_code_r  <= command_r[6:0];
			 cur_x_r    <= prev_x_r + 30;
			 next_x_r   <= prev_x_r + 30;
			 cur_y_r    <= prev_y_r;
			 state_r    <= 4;
		  end
		  else begin
		    // Unknown command, reset FSM
		    state_r      <= 0;
		  end
		end
    3:
      begin
		  x_from_r       <=        prev_x_r[10:2] + prev_x_r[10:4]; // 2048->640
		  y_from_r       <= 480 - (prev_y_r[10:2] - prev_y_r[10:6]);// 2048->480
		  x_to_r         <=         cur_x_r[10:2] +  cur_x_r[10:4]; // 2048->640
		  y_to_r         <= 480 - ( cur_y_r[10:2] -  cur_y_r[10:6]); // 2048->480
		  draw_en_r      <= 1;
		  state_r        <= 5;
      end
    4:
      begin
		  x_from_r       <=        prev_x_r[10:2] + prev_x_r[10:4]; // 2048->640
		  y_from_r       <= 480 - (prev_y_r[10:2] - prev_y_r[10:6]);// 2048->480
		  draw_text_en_r <= 1;
		  state_r        <= 5;
      end
    5:
      state_r          <= draw_busy ? 6 : 5;
    6:
	   begin
	     draw_en_r      <= 0;
		  draw_text_en_r <= 0;
		  state_r        <= !draw_busy ? 7 : 6;
		end
	 7: 
	   begin
		  prev_x_r     <= cur_x_r;
		  prev_y_r     <= cur_y_r;
		  state_r      <= 0;
	   end
	 endcase
  end
end


endmodule