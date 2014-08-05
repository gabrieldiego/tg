`timescale 10 us / 1 us
`define NULL 0

module compute_sad_tb;
  parameter STDIN = 32'h8000_0000;

  parameter prefix="/home/gabriel/Dev/tg/rtl/";
  parameter filename_cur="compute_sad_cur.txt";
  parameter filename_org="compute_sad_org.txt";
  parameter filepath_cur={prefix,filename_cur};
  parameter filepath_org={prefix,filename_org};

  integer    cur_file;
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

  wire [59:0] sad_UH;
  wire [59:0] sad_UQ;
  wire [59:0] sad_M;
  wire [59:0] sad_LQ;
  wire [59:0] sad_LH;

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

    for(i=0;i<8;i=i+1) begin
      c = $fscanf(cur_file,"%x",tmp);
      if(c != 1) begin
        $finish;
      end
      cur_array[i] = tmp;
    end

    cur_middle_pix = {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
                      cur_array[3],cur_array[2],cur_array[1],cur_array[0]};

    for(i=0;i<8;i=i+1) begin
      c = $fscanf(cur_file,"%x",tmp);
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
      c = $fscanf(cur_file,"%x",tmp);
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

    org_pix = {org_array[6],org_array[5],org_array[4],
               org_array[3],org_array[2],org_array[1]};

    for(i=0;i<8;i=i+1) begin
      $write("%x ",org_array[i]);
    end
    $write("\n\n");

    #1 $write("%3d %3d %3d %3d %3d\n", sad_M[11: 0], sad_M[23:12],
                         sad_M[35:24], sad_M[47:36], sad_M[59:48]);
  end

  compute_sad cs(cur_upper_pix, cur_middle_pix, cur_lower_pix, org_pix,
                 sad_UH, sad_UQ, sad_M, sad_LQ, sad_LH);

  initial begin
    $dumpfile("compute_sad.vcd");
    $dumpvars(0,compute_sad_tb);
  end

endmodule
