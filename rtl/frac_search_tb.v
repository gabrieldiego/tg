module frac_search_tb;

  reg [7:0] in=0;
  reg reset=0;

  initial
    begin
      #2 in = 4;
      #8 in = 17;
      #10 $finish();
    end

  wire [7:0] value;

  frac_search fs(in,value,clk,reset);

  reg clk = 0;
  always #1 clk = !clk;

  initial
    $monitor("At time %t value %d",$time,value);

endmodule
