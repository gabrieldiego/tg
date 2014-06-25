`timescale 10 us / 1 us

module frac_search_tb;

  reg [7:0] in=0;
  reg reset=0;

  wire [63:0] filter_pix2;
  wire [63:0] ref_pix2;

  reg         input_ready;

  integer tmp;
  integer c;
  integer i;

  parameter STDIN = 32'h8000_0000;

  wire [2:0] mvx, mvy;

  reg [7:0] filter_array[7:0];
  reg [7:0] ref_array[7:0];

  reg [63:0] filter_pix;
  reg [63:0] ref_pix;

  assign filter_pix2 =
    {filter_array[7],filter_array[6],filter_array[5],filter_array[4],
     filter_array[3],filter_array[2],filter_array[1],filter_array[0]};

  assign ref_pix2 = {ref_array[7],ref_array[6],ref_array[5],ref_array[4],
                    ref_array[3],ref_array[2],ref_array[1],ref_array[0]};

  initial begin
    @(posedge clk) begin
      reset = 1;
      input_ready = 0;
    end

    @(negedge clk) begin
      reset = 0;
      input_ready = 0;
    end

    forever begin
      @(posedge clk) begin
        for(i=0; i<8; i=i+1) begin
          c = $fscanf(STDIN,"%x",tmp);
          if(c != 1)
            $finish;

          filter_array[i] = tmp;
        end

        for(i=0; i<8; i=i+1) begin
          c = $fscanf(STDIN,"%x",tmp);
          if(c != 1)
            $finish;

          ref_array[i] = tmp;
        end

        filter_pix <= #1 filter_pix2;
        ref_pix <= #1 ref_pix2;
        input_ready <= #1 1;

      end
    end
  end

  frac_search fs(filter_pix,ref_pix,input_ready,mvx,mvy,clk,reset);

  reg clk = 0;
  always #10 clk = !clk;

  initial
    $monitor("At time %t value %d %d",$time,mvx,mvy);

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,fs);
  end

endmodule
