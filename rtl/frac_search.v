module frac_search(filter_pix, ref_pix, in, out, clk, reset);
  input [127:0] filter_pix;
  input [63:0] ref_pix;
  input [7:0] in;
  output [7:0] out;
  input clk,reset;

  wire [127:0] filter_pix;
  wire [63:0] ref_pix;
  wire [7:0] in;
  reg  [7:0] out;
  wire clk, reset;

  reg [127:0] pix_buffer[2:0];
  reg [3:0]   pix_counter;

  parameter HEIGHT = 8;
  parameter TAPS = 8;
  parameter HALF_TAPS = 3; // Index of the center of the filter

  parameter PADDED_CU = 16;

  reg [2:0]   state;
  parameter IDLE = 0,RECP = 1;

  /*
   States of the FSM:
   1-Ready to receive another block to filter
   2-Receiving lines of block to filter but not ref block
     -Should fill the number of taps to start calculation
   3-Receiving lines of block to filter and ref block
   4-Calculation ready
   */

  always @(posedge clk)
    if (reset == 1'b1) begin
      pix_counter <= 0;
      state <= IDLE;
    end
    else begin
      out <= in+1;
      pix_buffer[pix_counter][127:0] <= filter_pix;
      pix_counter = pix_counter+1;
    end

endmodule
