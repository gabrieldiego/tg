`timescale 10 us / 1 us
`define NULL 0

module abs_diff_line_tb;
  parameter STDIN = 32'h8000_0000;

  parameter prefix="/home/gabriel/Dev/tg/rtl/";
  parameter filename="abs_diff_line.txt";
  parameter filename_org="abs_diff_line_org.txt";
  parameter filepath={prefix,filename};
  parameter filepath_org={prefix,filename_org};

  integer    input_file;
  integer    org_file;
  integer    i,c,tmp;

  reg        clk;

  reg [63:0] cur_upper_pix;
  reg [63:0] cur_middle_pix;
  reg [63:0] cur_lower_pix;
  reg [55:8] org_pix;

  reg [7:0]   cur_array[7:0];
  reg [7:0]   org_array[7:0];

  reg [7:0]   s_array[5:0];
  reg [7:0]   d_array[11:0];

  wire [47:0] diff_UH_h;
  wire [47:0] diff_UH_q;
  wire [47:0] diff_UH_f;
  wire [47:0] diff_UH_r;
  wire [47:0] diff_UH_i;

  wire [47:0] diff_UQ_h;
  wire [47:0] diff_UQ_q;
  wire [47:0] diff_UQ_f;
  wire [47:0] diff_UQ_r;
  wire [47:0] diff_UQ_i;

  wire [47:0] diff_M_h;
  wire [47:0] diff_M_q;
  wire [47:0] diff_M_f;
  wire [47:0] diff_M_r;
  wire [47:0] diff_M_i;

  wire [47:0] diff_LQ_h;
  wire [47:0] diff_LQ_q;
  wire [47:0] diff_LQ_f;
  wire [47:0] diff_LQ_r;
  wire [47:0] diff_LQ_i;

  wire [47:0] diff_LH_h;
  wire [47:0] diff_LH_q;
  wire [47:0] diff_LH_f;
  wire [47:0] diff_LH_r;
  wire [47:0] diff_LH_i;


  initial begin
    input_file = $fopen(filepath, "r");
    if (input_file == `NULL) begin
      $display({"Cannot open file ",filepath});
      $finish;
    end

    org_file = $fopen(filepath_org, "r");
    if (org_file == `NULL) begin
      $display({"Cannot open file ",filepath_org});
      $finish;
    end

    for(i=0;i<8;i=i+1) begin
      c = $fscanf(input_file,"%x",tmp);
      if(c != 1) begin
        $finish;
      end
      cur_array[i] = tmp;
    end

    cur_middle_pix = {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
                     cur_array[3],cur_array[2],cur_array[1],cur_array[0]};

    for(i=0;i<8;i=i+1) begin
      c = $fscanf(input_file,"%x",tmp);
      if(c != 1) begin
        $finish;
      end
      cur_array[i] = tmp;
    end

    cur_lower_pix = {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
                     cur_array[3],cur_array[2],cur_array[1],cur_array[0]};
  end

  initial begin
    clk = 0;
    i = 0;
    forever begin
      clk = #10 ~clk;
    end
  end

  always @(posedge clk) begin
    cur_upper_pix  = cur_middle_pix;
    cur_middle_pix = cur_lower_pix;

    for(i=0;i<8;i=i+1) begin
      c = $fscanf(input_file,"%x",tmp);
      if(c != 1) begin
        $finish;
      end
      cur_array[i] = tmp;
    end

    cur_lower_pix = {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
                     cur_array[3],cur_array[2],cur_array[1],cur_array[0]};


    {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
     cur_array[3],cur_array[2],cur_array[1],cur_array[0]} = cur_upper_pix;

    for(i=0;i<8;i=i+1) begin
      $write("%x ",cur_array[i]);
    end
    $write("\n");

    {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
     cur_array[3],cur_array[2],cur_array[1],cur_array[0]} = cur_middle_pix;

    for(i=0;i<8;i=i+1) begin
      $write("%x ",cur_array[i]);
    end
    $write("\n");

    {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
     cur_array[3],cur_array[2],cur_array[1],cur_array[0]} = cur_lower_pix;

    for(i=0;i<8;i=i+1) begin
      $write("%x ",cur_array[i]);
    end
    $write("\n\n");

    for(i=0;i<8;i=i+1) begin
      c = $fscanf(org_file,"%x",tmp);
      if(c != 1) begin
        $finish;
      end
      org_array[i] = tmp;
    end

    org_pix = {org_array[7],org_array[6],org_array[5],org_array[4],
               org_array[3],org_array[2],org_array[1],org_array[0]};

    for(i=0;i<8;i=i+1) begin
      $write("%x ",org_array[i]);
    end
    $write("\n\n");

    #1 $write("%2x %2x %2x %2x %2x %2x\n", diff_M_f[ 7: 0],diff_M_f[15: 8],
           diff_M_f[23:16],diff_M_f[31:24],diff_M_f[39:32],diff_M_f[47:40]);

  end

  abs_diff_line  abl(cur_upper_pix, cur_middle_pix ,cur_lower_pix, org_pix,
                     diff_UH_h, diff_UH_q, diff_UH_f, diff_UH_r, diff_UH_i,
                     diff_UQ_h, diff_UQ_q, diff_UQ_f, diff_UQ_r, diff_UQ_i,
                     diff_M_h , diff_M_q , diff_M_f , diff_M_r , diff_M_i ,
                     diff_LQ_h, diff_LQ_q, diff_LQ_f, diff_LQ_r, diff_LQ_i,
                     diff_LH_h, diff_LH_q, diff_LH_f, diff_LH_r, diff_LH_i);

  initial begin
    $dumpfile("abs_diff_line.vcd");
    $dumpvars(0,abs_diff_line_tb);
  end

endmodule
