module framebuffer(clk, rst, enable, page_in, x, y, r_out, g_out, b_out, SRAM_ADDR, SRAM_DQ, SRAM_OE_N, SRAM_WE_N, SRAM_CE_N, SRAM_LB_N, SRAM_UB_N);

parameter     WRITE_BACK = 1;

input         clk;
input         rst;
input         enable;
input         page_in;
input   [9:0] x;
input   [9:0] y;
output  [5:0] r_out;
output  [5:0] g_out;
output  [5:0] b_out;
output [19:0] SRAM_ADDR;
inout  [15:0] SRAM_DQ; // 
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_CE_N;
output        SRAM_LB_N;
output        SRAM_UB_N;

reg    [19:0] r_sram_addr;
reg    [19:0] r_page_base;
reg    [2:0]  r_sram_br [31:0];
reg    [2:0]  r_sram_nbr[31:0];
reg    [1:0]  r_sram_r  [31:0];
reg    [1:0]  r_sram_g  [31:0];
reg           r_sram_b  [31:0];


reg    [5:0]  r_sram_r_o;
reg    [5:0]  r_sram_g_o;
reg    [5:0]  r_sram_b_o;

reg    [3:0] r_x;
reg          r_state;

assign SRAM_UB_N = enable           ? 0                             : 1'bz;
assign SRAM_LB_N = enable           ? 0                             : 1'bz;
assign SRAM_WE_N = enable           ? ~r_state | clk | ~WRITE_BACK  : 1'bz;
assign SRAM_OE_N = enable           ? r_state                       : 1'bz;
assign SRAM_CE_N = enable           ? 0                             : 1'bz;
assign SRAM_ADDR = enable           ? r_sram_addr                   : 20'hzzzzz;

assign r_out     = enable ? r_sram_r_o : 6'hzz;
assign g_out     = enable ? r_sram_g_o : 6'hzz;
assign b_out     = enable ? r_sram_b_o : 6'hzz;

assign SRAM_DQ = enable & r_state & WRITE_BACK ? 
                {r_sram_nbr[{r_x,1'b1}],
					  r_sram_r  [{r_x,1'b1}],
					  r_sram_g  [{r_x,1'b1}],
					  r_sram_b  [{r_x,1'b1}],
					  r_sram_nbr[{r_x,1'b0}],
					  r_sram_r  [{r_x,1'b0}],
					  r_sram_g  [{r_x,1'b0}],
					  r_sram_b  [{r_x,1'b0}]} :
					 16'hzzzz;

always @ (posedge clk or posedge rst) begin
  if (rst) begin
    r_sram_addr     <= 20'h00000;
	 r_page_base     <= 20'h00000;
	 r_state         <= 1'b0;
	 r_x             <= 4'h0;
  end
  else begin
    if (enable) begin
      if (x[3:0] == 4'h0) begin
	     r_sram_addr   <= {y, 8'h00} + {y, 6'h00} + {x[9:5], 4'h0} + {page_in, 17'h00000} + {page_in, 16'h00000};
		  r_state         <= x[4];
		  r_x             <= 0;
		end
	   else begin
	     r_sram_addr     <= r_sram_addr + 1;
		  r_x             <= r_x + 1;
	   end
    end
  end
end

wire       first = r_sram_addr[3:0] == 0 && !r_state;
wire [2:0] br    = first ?       SRAM_DQ[7:5] :  r_sram_br[{r_state, r_x}];
wire [1:0]  r    = first ?       SRAM_DQ[4:3] :  r_sram_r [{r_state, r_x}];
wire [1:0]  g    = first ?       SRAM_DQ[2:1] :  r_sram_g [{r_state, r_x}];
wire [1:0]  b    = first ? {SRAM_DQ[0], 1'b0} : {r_sram_b [{r_state, r_x}], 1'b0};

always @ (negedge clk or posedge rst) begin
  if (rst) begin
    r_sram_r_o                <= 0;
    r_sram_g_o                <= 0;
    r_sram_b_o                <= 0;
  end
  else begin
    if (enable) begin
	   if (!r_state) begin
		  r_sram_br [{r_x,1'b1}] <= SRAM_DQ[15:13];
        r_sram_r  [{r_x,1'b1}] <= SRAM_DQ[12:11];
		  r_sram_g  [{r_x,1'b1}] <= SRAM_DQ[10:9];
		  r_sram_b  [{r_x,1'b1}] <= SRAM_DQ[8];
		  r_sram_nbr[{r_x,1'b1}] <= SRAM_DQ[15:13] == 0 ? 0 : SRAM_DQ[15:13] - 1;
		  
		  r_sram_br [{r_x,1'b0}] <= SRAM_DQ[7:5];
		  r_sram_r  [{r_x,1'b0}] <= SRAM_DQ[4:3];
		  r_sram_g  [{r_x,1'b0}] <= SRAM_DQ[2:1];
		  r_sram_b  [{r_x,1'b0}] <= SRAM_DQ[0];
		  r_sram_nbr[{r_x,1'b0}] <= SRAM_DQ[7:5]   == 0 ? 0 : SRAM_DQ[7:5]   - 1;
		end
		
		r_sram_r_o              <= {(br[2] ? r : 2'b00), 3'b000} + {(br[1] ? r : 2'b00), 2'b00} + {(br[0] ? r : 2'b00), 1'b0};
		r_sram_g_o              <= {(br[2] ? g : 2'b00), 3'b000} + {(br[1] ? g : 2'b00), 2'b00} + {(br[0] ? g : 2'b00), 1'b0};
		r_sram_b_o              <= {(br[2] ? b : 2'b00), 3'b000} + {(br[1] ? b : 2'b00), 2'b00} + {(br[0] ? b : 2'b00), 1'b0};		
		
		
//		r_sram_r_o              <= r_sram_addr[3:0] == 0 && !r_state ? {SRAM_DQ[4:3],              4'b0000 } >> SRAM_DQ[7:5] :
//	                                                     	            {r_sram_r [{r_state, r_x}], 4'b0000 } >> r_sram_br[{r_state, r_x}];
//		r_sram_g_o              <= r_sram_addr[3:0] == 0 && !r_state ? {SRAM_DQ[2:1],              4'b0000 } >> SRAM_DQ[7:5] :
//	                                                   	            {r_sram_g [{r_state, r_x}], 4'b0000 } >> r_sram_br[{r_state, r_x}];
//		r_sram_b_o              <= r_sram_addr[3:0] == 0 && !r_state ? {SRAM_DQ[0],                5'b00000} >> SRAM_DQ[7:5] :
//	                                                   	            {r_sram_b [{r_state, r_x}], 5'b00000} >> r_sram_br[{r_state, r_x}];
    end
  end
end

endmodule