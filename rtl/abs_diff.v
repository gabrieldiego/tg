module abs_diff(a, b, out);
  input [7:0] a,b;
  output [7:0] out;

  wire [7:0] a,b;
  wire [7:0] out;

  wire [8:0]   diff;
  wire         carry;
  wire [7:0]   diff8;

  assign diff = a + (~b) + 1;

  assign carry = diff[8];
  assign diff8 = diff[7:0];

  assign out = carry?(~diff8)+1:diff8;

endmodule
