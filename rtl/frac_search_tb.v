module frac_search_tb;

  reg [7:0] in=0;
  reg reset=0;

  wire [63:0] filter_pix;
  wire [63:0] ref_pix;
  integer tmp;
  integer c;
  integer i;

  parameter STDIN = 32'h8000_0000;

  wire [2:0] mvx, mvy;


  reg [7:0] filter_array[7:0];
  reg [7:0] ref_array[7:0];

  assign filter_pix = {filter_array[7],filter_array[6],filter_array[5],filter_array[4],
                       filter_array[3],filter_array[2],filter_array[1],filter_array[0]};

  assign ref_pix = {ref_array[7],ref_array[6],ref_array[5],ref_array[4],
                    ref_array[3],ref_array[2],ref_array[1],ref_array[0]};

  initial begin
    @(posedge clk)
      reset = 1;

    @(negedge clk)
      reset = 0;

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

      end
    end
  end

  frac_search fs(filter_pix,ref_pix,1'b1,mvx,mvy,clk,reset);

  reg clk = 0;
  always #1 clk = !clk;

  initial
    $monitor("At time %t value %d %d",$time,mvx,mvy);

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,fs);
  end

endmodule
