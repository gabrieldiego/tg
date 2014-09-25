`timescale 10 us / 1 us
`define NULL 0

module frac_search_tb;
  parameter STDIN = 32'h8000_0000;

  parameter     prefix="/home/gabriel/Dev/tg/rtl/";
  parameter     filename_cur="frac_search_cur.txt";
  parameter     filename_org="frac_search_org.txt";
  parameter     filename_mv="frac_search_mv.txt";
  parameter     filepath_cur={prefix,filename_cur};
  parameter     filepath_org={prefix,filename_org};
  parameter     filepath_mv={prefix,filename_mv};

  integer       cur_file;
  integer       org_file;
  integer       mv_file;
  integer       i,j,c,tmp;

  reg           clk, reset;

  reg [63:0]    cur_pix;
  reg [55:8]    org_pix;
  reg [2:0]     org_mvx;
  reg [2:0]     org_mvy;
  reg           ready;

  wire [11:0] sad_out;
  wire [2:0]  mvx;
  wire [2:0]  mvy;

  reg [7:0]   cur_array[7:0];
  reg [7:0]   org_array[7:0];

  genvar          g;

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

    mv_file = $fopen(filepath_mv, "r");
    if (mv_file == `NULL) begin
      $display({"Cannot open file ",filepath_mv});
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
    reset = 1;

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
            cur_pix = {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
                       cur_array[3],cur_array[2],cur_array[1],cur_array[0]};

/*            $write("cur: ");
            for(i=0;i<8;i=i+1) begin
              $write("%x ",cur_array[i]);
            end
            $write("\n");*/
          end

        if(j!=0) begin
          // Read the first line only in the second cycle
          for(i=0;i<8;i=i+1) begin
            c = $fscanf(org_file,"%x",tmp);
            if(c != 1) begin
              $finish;
            end
            org_array[i] = tmp;
          end

          org_pix = {org_array[6],org_array[5],org_array[4],
                     org_array[3],org_array[2],org_array[1]};

/*          $write("org: ");
          for(i=0;i<8;i=i+1) begin
            $write("%x ",org_array[i]);
          end
          $write("\n");*/
        end

        #1 if(j>2) begin
/*          $write("UHh:");
          $write("%3x",fs.cs.abl.UH_h[7:0]);
          $write("%3x",fs.cs.abl.UH_h[15:8]);
          $write("%3x",fs.cs.abl.UH_h[23:16]);
          $write("%3x",fs.cs.abl.UH_h[31:24]);
          $write("%3x",fs.cs.abl.UH_h[39:32]);
          $write("%3x",fs.cs.abl.UH_h[47:40]);
          $write("\n");*/
/*
          $write("UHf:");
          $write("%3x",fs.cs.abl.UH_f[7:0]);
          $write("%3x",fs.cs.abl.UH_f[15:8]);
          $write("%3x",fs.cs.abl.UH_f[23:16]);
          $write("%3x",fs.cs.abl.UH_f[31:24]);
          $write("%3x",fs.cs.abl.UH_f[39:32]);
          $write("%3x",fs.cs.abl.UH_f[47:40]);
          $write("%3x",fs.cs.abl.UH_f[55:48]);
          $write("%3x",fs.cs.abl.UH_f[63:56]);
          $write("\n");

          $write("Mq:");
          $write("%3x",fs.cs.abl.M_q[7:0]);
          $write("%3x",fs.cs.abl.M_q[23:16]);
          $write("%3x",fs.cs.abl.M_q[39:32]);
          $write("%3x",fs.cs.abl.M_q[55:48]);
          $write("%3x",fs.cs.abl.M_q[71:64]);
          $write("%3x",fs.cs.abl.M_q[87:80]);
          $write("\n");

          $write("Mq:");
          $write("%3x",fs.cs.abl.M_q[31:24]);
          $write("%3x",fs.cs.abl.M_q[47:40]);
          $write("%3x",fs.cs.abl.M_q[63:56]);
          $write("%3x",fs.cs.abl.M_q[79:72]);
          $write("%3x",fs.cs.abl.M_q[95:88]);
          $write("%3x",fs.cs.abl.M_q[111:104]);
          $write("\n");

          $write("UHq:");
          $write("%3x",fs.cs.abl.UH_q[7:0]);
          $write("%3x",fs.cs.abl.UH_q[23:16]);
          $write("%3x",fs.cs.abl.UH_q[39:32]);
          $write("%3x",fs.cs.abl.UH_q[55:48]);
          $write("%3x",fs.cs.abl.UH_q[71:64]);
          $write("%3x",fs.cs.abl.UH_q[87:80]);
          $write("\n");

          $write("UQ_r:");
          $write("%3x",fs.cs.abl.UQ_r[7:0]);
          $write("%3x",fs.cs.abl.UQ_r[15:8]);
          $write("%3x",fs.cs.abl.UQ_r[23:16]);
          $write("%3x",fs.cs.abl.UQ_r[31:24]);
          $write("%3x",fs.cs.abl.UQ_r[39:32]);
          $write("%3x",fs.cs.abl.UQ_r[47:40]);
          $write("\n");

          $write("org_pix:");
          $write("%3x",fs.cs.abl.org_pix[15:8]);
          $write("%3x",fs.cs.abl.org_pix[23:16]);
          $write("%3x",fs.cs.abl.org_pix[31:24]);
          $write("%3x",fs.cs.abl.org_pix[39:32]);
          $write("%3x",fs.cs.abl.org_pix[47:40]);
          $write("%3x",fs.cs.abl.org_pix[55:48]);
          $write("\n");

          $write("UF_q:");
          $write("%3x",fs.cs.abl.UF_q[15:8]);
          $write("%3x",fs.cs.abl.UF_q[31:24]);
          $write("%3x",fs.cs.abl.UF_q[47:40]);
          $write("%3x",fs.cs.abl.UF_q[63:56]);
          $write("%3x",fs.cs.abl.UF_q[79:72]);
          $write("%3x",fs.cs.abl.UF_q[95:88]);
          $write("\n");*/

        end

        if(j!=8)
          @(negedge clk);
        else begin
          ready = 0;
          c = $fscanf(mv_file,"%d",tmp);
          org_mvx = tmp+2;
          c = $fscanf(mv_file,"%d",tmp);
          org_mvy = tmp+2;
        end
      end

      $write("sad: %4x\n", sad_out);
//      $write("mvs    : %d %d\n", mvx, mvy);
//      $write("org_mvs: %d %d\n", org_mvx, org_mvy);

      if(org_mvx == mvx && org_mvy == mvy) begin
        $write("Motion vectors check\n");
      end
      else begin
        $write("Motion vectors DO NOT CHECK\n");
        $finish();
      end

/*      $write("sads:\n");
      for(i=0;i<5;i=i+1) begin
        $write("%5x",fs.next_sad_UH[i]);
      end
      $write("\n");
      for(i=0;i<5;i=i+1) begin
        $write("%5x",fs.next_sad_UQ[i]);
      end
      $write("\n");
      for(i=0;i<5;i=i+1) begin
        $write("%5x",fs.next_sad_M[i]);
      end
      $write("\n");
      for(i=0;i<5;i=i+1) begin
        $write("%5x",fs.next_sad_LQ[i]);
      end
      $write("\n");
      for(i=0;i<5;i=i+1) begin
        $write("%5x",fs.next_sad_LH[i]);
      end*/
//      $write("\n");

//      $write("\n");
    end
  end

  frac_search fs(cur_pix, org_pix, ready, sad_out, mvx, mvy, clk, reset);

//  initial begin
//    $dumpfile("frac_search.vcd");
//    $dumpvars(0,frac_search_tb);
//  end

endmodule
