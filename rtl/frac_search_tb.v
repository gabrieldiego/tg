module frac_search_tb;

  reg [7:0] in=0;
  reg reset=0;
  reg [127:0] filter_pix;
  reg [63:0] ref_pix;

  integer tmp;
  integer c;

  parameter STDIN = 32'h8000_0000;

  initial begin
    @(posedge clk)
      reset = 1;

    @(negedge clk)
      reset = 0;

    forever begin
      @(posedge clk) begin
        c = $fscanf(STDIN,"%d",tmp);
        in = tmp;
        if(c != 1)
          $finish;
      end
    end
  end

  wire [7:0] value;

  frac_search fs(filter_pix,ref_pix,in,value,clk,reset);

  reg clk = 0;
  always #1 clk = !clk;

  initial
    $monitor("At time %t value %d",$time,value);

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,fs);
  end

endmodule
