module filter_half(cur_pix, filter_pix);
  input  [63:0] cur_pix;
  output [55:0] filter_pix;

  genvar          i;

  generate
    for(i=0; i<56; i=i+8) begin: line_generate
      assign filter_pix[i+7:i] = (cur_pix[i+7:i] + cur_pix[i+15:i+8])/2;
      // The resulting sum is 9 bit, but the division will bring the total back to 8
      // TODO: Must test to see if synthesizer will do this right using 255 as input
    end
  endgenerate
endmodule
