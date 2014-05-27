module frac_search(in, out, clk, reset);
  input [7:0] in;
  output [7:0] out;
  input clk,reset;

  wire [7:0] in;
  reg [7:0]  out;
  wire  clk,reset;

  always @(posedge clk)
  begin
    out <= in+1;
  end
endmodule
