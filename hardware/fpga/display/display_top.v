module display_top(clk, rst, draw_en_out, SRAM_ADDR, SRAM_DQ, SRAM_OE_N, SRAM_WE_N, SRAM_CE_N, SRAM_LB_N, SRAM_UB_N, VGA_CLK, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS);
input         clk;
input         rst;
output        draw_en_out;

output [19:0] SRAM_ADDR;
inout  [15:0] SRAM_DQ;
output        SRAM_OE_N;
output        SRAM_WE_N;
output        SRAM_CE_N;
output        SRAM_LB_N;
output        SRAM_UB_N;
output        VGA_CLK;
output  [7:0] VGA_R;
output  [7:0] VGA_G;
output  [7:0] VGA_B;
output        VGA_HS;
output        VGA_VS;

wire       w_vga_draw;
wire       w_page = 0;
wire [9:0] w_vga_x;
wire [9:0] w_vga_y;
wire [5:0] w_vga_fc;
wire [5:0] w_vga_r;
wire [5:0] w_vga_g;
wire [5:0] w_vga_b;

framebuffer(
  .clk       (clk),
  .rst       (rst),
  .enable    (w_vga_draw),
  .page_in   (w_page),
  .x         (w_vga_x),
  .y         (w_vga_y),
  .fc        (w_vga_fc),
  .r_out     (w_vga_r),
  .g_out     (w_vga_g),
  .b_out     (w_vga_b),
  .SRAM_ADDR (SRAM_ADDR),
  .SRAM_DQ   (SRAM_DQ),
  .SRAM_OE_N (SRAM_OE_N),
  .SRAM_WE_N (SRAM_WE_N),
  .SRAM_CE_N (SRAM_CE_N),
  .SRAM_LB_N (SRAM_LB_N),
  .SRAM_UB_N (SRAM_UB_N));
  
  
vga(
  .clk         (clk),
  .rst         (rst),
  .x_out       (w_vga_x),
  .y_out       (w_vga_y),
  .fc_out      (w_vga_fc),
  .fb_en_out   (w_vga_draw),
  .draw_en_out (draw_en_out),
  .r_in        (w_vga_r),
  .g_in        (w_vga_g),
  .b_in        (w_vga_b),
  .VGA_CLK     (VGA_CLK),
  .VGA_R       (VGA_R),
  .VGA_G       (VGA_G),
  .VGA_B       (VGA_B),
  .VGA_HS      (VGA_HS),
  .VGA_VS      (VGA_VS)
);

endmodule