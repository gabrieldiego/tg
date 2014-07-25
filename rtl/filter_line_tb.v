`timescale 10 us / 1 us
`define NULL 0

module filter_line_tb;
  parameter STDIN = 32'h8000_0000;

  parameter prefix="/home/gabriel/Dev/tg/rtl/";
  parameter filename="filter_line.txt";
  parameter filepath={prefix,filename};

  integer    input_file;
  integer    i,c,tmp;


  reg        clk;
  wire [63:0] cur_pix;
  wire [55:0] half_pix;
  wire [111:0] quarter_pix;

  reg [7:0]   cur_array[7:0];
  wire [7:0]  half_array[6:0];
  wire [7:0]  quarter_array[14:0];

  assign cur_pix = {cur_array[7],cur_array[6],cur_array[5],cur_array[4],
                    cur_array[3],cur_array[2],cur_array[1],cur_array[0]};

  assign {half_array[6],half_array[5],half_array[4],half_array[3],
          half_array[2],half_array[1],half_array[0]} = half_pix;

  assign {quarter_array[13],quarter_array[12],quarter_array[11],
          quarter_array[10],quarter_array[9] ,quarter_array[8] ,quarter_array[7],
          quarter_array[6] ,quarter_array[5] ,quarter_array[4] ,quarter_array[3],
          quarter_array[2] ,quarter_array[1] ,quarter_array[0] } = quarter_pix;

  initial begin
    input_file = $fopen(filepath, "r");
    if (input_file == `NULL) begin
      $display({"Cannot open file ",filepath});
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

  always @(posedge clk) begin
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

  filter_half    fh(cur_pix,half_pix);
  filter_quarter fq(cur_pix,quarter_pix);

  initial begin
    $dumpfile("filter_half.vcd");
    $dumpvars(0,fh);
    $dumpvars(0,fq);
  end



endmodule
