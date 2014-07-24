`timescale 10 us / 1 us
`define NULL 0

module compute_sad_tb;
  parameter STDIN = 32'h8000_0000;

  parameter prefix="/home/gabriel/Dev/tg/rtl/";
  parameter filename="compute_sad.txt";
  parameter filepath={prefix,filename};

  integer    input_file;

  initial begin
    input_file = $fopen(filepath, "r");
    if (input_file == `NULL) begin
      $display({"Cannot open file ",filepath});
      $finish;
    end
  end

endmodule
