`timescale 10 us / 1 us
`define NULL 0

module abs_diff_line_tb;
  parameter STDIN = 32'h8000_0000;

  parameter prefix="/home/gabriel/Dev/tg/rtl/";
  parameter filename="abs_diff_line.txt";
  parameter filepath={prefix,filename};

  integer    input_file;
  integer    i,c,tmp;

  reg        clk;

  reg [63:0] cur_upper_pix;
  reg [63:0] cur_middle_pix;
  reg [63:0] cur_lower_pix;
  reg [63:0] org_pix;

  wire [7:0]   cur_array[7:0];
  wire [7:0]   org_array[7:0];

  assign {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
          cur_array[3],cur_array[2],cur_array[1],cur_array[0]} = cur_lower_pix;

  assign {org_array[7],org_array[6],org_array[5],org_array[4],
          org_array[3],org_array[2],org_array[1],org_array[0]} = org_pix;


  wire [111:0] diff_UH_h;
  wire [111:0] diff_UH_q;
  wire [ 55:0] diff_UH_f;

  wire [111:0] diff_UQ_h;
  wire [111:0] diff_UQ_q;
  wire [ 55:0] diff_UQ_f;

  wire [111:0] diff_M_h;
  wire [111:0] diff_M_q;
  wire [ 55:0] diff_M_f;

  wire [111:0] diff_LQ_h;
  wire [111:0] diff_LQ_q;
  wire [ 55:0] diff_LQ_f;

  wire [111:0] diff_LH_h;
  wire [111:0] diff_LH_q;
  wire [ 55:0] diff_LH_f;


  initial begin
    input_file = $fopen(filepath, "r");
    if (input_file == `NULL) begin
      $display({"Cannot open file ",filepath});
      $finish;
    end

    for(i=0;i<64;i=i+8) begin
      c = $fscanf(input_file,"%x",tmp);
      if(c != 1) begin
        $finish;
      end
      cur_middle_array[i+7:i] = tmp;
    end

    for(i=0;i<64;i=i+8) begin
      c = $fscanf(input_file,"%x",tmp);
      if(c != 1) begin
        $finish;
      end
      cur_lower_array[i+7:i] = tmp;
    end
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

    #1 for(i=0;i<7;i=i+1) begin
      $write("%2x ",half_array[i]);
    end
    $write("\n");

    for(i=0;i<14;i=i+1) begin
      $write("%2x ",quarter_array[i]);
    end
    $write("\n");

  end

  abs_diff_line  abl(cur_upper_pix, cur_middle_pix ,cur_lower_pix, org_pix,
                     diff_UH_h, diff_UH_q, diff_UH_f,
                     diff_UQ_h, diff_UQ_q, diff_UQ_f,
                     diff_M_h , diff_M_q , diff_M_f ,
                     diff_LQ_h, diff_LQ_q, diff_LQ_f,
                     diff_LH_h, diff_LH_q, diff_LH_f);

  initial begin
    $dumpfile("abs_diff_line.vcd");
    $dumpvars(0,abl);
  end

endmodule
