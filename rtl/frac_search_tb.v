`timescale 10 us / 1 us
`define NULL 0

module frac_search_tb;
  parameter STDIN = 32'h8000_0000;

  parameter     prefix="/home/gabriel/Dev/tg/rtl/";
  parameter     filename_cur="frac_search_cur.txt";
  parameter     filename_org="frac_search_org.txt";
  parameter     filepath_cur={prefix,filename_cur};
  parameter     filepath_org={prefix,filename_org};

  integer       cur_file;
  integer       org_file;
  integer       i,j,c,tmp;

  reg           clk, reset;

  reg [63:0]    cur_pix;
  reg [55:8]    org_pix;
  reg           ready;

  wire [11:0] sad_out;
  wire [2:0]  mvx;
  wire [2:0]  mvy;

  reg [7:0]   cur_array[7:0];
  reg [7:0]   org_array[7:0];

  initial begin
    cur_file = $fopen(filepath_cur, "r");
    if (cur_file == `NULL) begin
      $display({"Cannot open file ",filepath_cur});
      $finish;
    end

    org_file = $fopen(filepath_org, "r");
    if (org_file == `NULL) begin
      $display({"Cannot open file ",filepath_org});
      $finish;
    end
  end

  initial begin
    clk = 0;
    i = 0;
    forever begin
      clk = #10 ~clk;
    end
  end

  initial begin
    ready = 0;

    @(negedge clk) reset = 1;
    @(negedge clk) reset = 0;

    forever @(negedge clk) begin
      ready = 1;

      for(j=0;j<=8;j=j+1) begin
          if(j!=8) begin
          // Skip the last read since it is to flush last row of org pixels
          for(i=0;i<8;i=i+1) begin
            c = $fscanf(cur_file,"%x",tmp);
            if(c != 1) begin
              $finish;
            end
            cur_array[i] = tmp;
          end
        end

        cur_pix = {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
                   cur_array[3],cur_array[2],cur_array[1],cur_array[0]};

        for(i=0;i<8;i=i+1) begin
          $write("%x ",cur_array[i]);
        end
        $write("\n\n");

        if(j!=0) begin
          // Read the first line only in the second cycle
          for(i=0;i<8;i=i+1) begin
            c = $fscanf(org_file,"%x",tmp);
            if(c != 1) begin
              $finish;
            end
            org_array[i] = tmp;
          end
        end

        org_pix = {org_array[6],org_array[5],org_array[4],
                   org_array[3],org_array[2],org_array[1]};

        for(i=0;i<8;i=i+1) begin
          $write("%x ",org_array[i]);
        end
        $write("\n\n");

        if(j!=8)
          @(negedge clk);
      end

      #1 $write("%4d %d %d\n", sad_out, mvx, mvy);
    end
  end

  frac_search fs(cur_pix, org_pix, ready, sad_out, mvx, mvy, clk, reset);

  initial begin
    $dumpfile("frac_search.vcd");
    $dumpvars(0,frac_search_tb);
  end

endmodule
