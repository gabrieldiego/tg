module compute_sad(filter_pix, ref_pix, input_ready, sad);
  input [63:0] filter_pix;
  input [63:0] ref_pix;
  input        input_ready;

  output [12*5:0] sad;
  // 12 bits for each result sad the difference of each pixel is 9 bits wide
  // and there are 6 integers of 9 bits to add, thus we use 3 extra bits.

  /*
   The SAD will be calculated only in the horizontal direction 
   for all five possible locations in this direction:
   Right Half, Right Quarter, Full, Left Quarter, Left Half
   
   The Half and Quarter subsamples will be only computed where there are pixels
   to their left and right (which excludes the samples that are outside the block)
   */

  /* Follow this rule to the index of the arrays:
   H -> hpel -> half pixel sample
   Q -> qpel -> quarter pixel sample
   F -> full -> full pixel
   
   Sample: FQHQ FQHQ FQHQ FQHQ FQHQ FQHQ FQHQ F
   Index:  0001 1213 2425 3637 4849 5151 6161 7
                                     0 1  2 3

   The interpolation to be used is linear: H[i] = (F[i] + F[i+1]) / 2
   */

  wire [7:0]      filter_array[7:0]; // Can't use vector as input, so we declare as a wire
  wire [7:0]      ref_array[7:0];
  wire [12:0]     sad_array[4:0];

  assign {filter_array[7],filter_array[6],filter_array[5],filter_array[4],
          filter_array[3],filter_array[2],filter_array[1],filter_array[0]} = filter_pix;

  assign {ref_array[7],ref_array[6],ref_array[5],ref_array[4],
          ref_array[3],ref_array[2],ref_array[1],ref_array[0]} = ref_pix;

  assign sad = {sad_array[4],sad_array[3],sad_array[2],sad_array[1],sad_array[0]};

  wire [7:0]      hpel[6:0];
  wire [7:0]      qpel[13:0];

  genvar          i;
  generate
    for(i=0; i<=6; i=i+1) begin
      assign hpel[i] = (filter_array[i] + filter_array[i+1])>>1;
      // The resulting sum is 9 bit, but the shift will bring the total back to 8
      // TODO: Must test to see if synthesizer will do this right using 255 as input
    end
  endgenerate

  generate
    for(i=0; i<=6; i=i+1) begin
      assign qpel[2*i]   = (3*filter_array[i] +   filter_array[i+1])>>2;
      assign qpel[2*i+1] = (  filter_array[i] + 3*filter_array[i+1])>>2;
      // Same here but the rounding is 10 bit to 8
      // TODO: Also test for the extreme cases in syntesizer
    end
  endgenerate

  // Each diff must contain one extra bit because the result lies in [-255..255]
  wire signed [8:0] diff_left_quarter[6:1];
  wire signed [8:0] diff_left_half[6:1];
  wire signed [8:0] diff_full_pixel[6:1];
  wire signed [8:0] diff_right_half[6:1];
  wire signed [8:0] diff_right_quarter[6:1];

  generate
    for(i=1; i<=6; i=i+1) begin
      assign diff_left_quarter[i] = qpel[2*i-1] - ref_array[i];
      assign diff_left_half[i] = hpel[i-1] - ref_array[i];
      assign diff_full_pixel[i] = filter_array[i] - ref_array[i];
      assign diff_right_half[i] = hpel[i] - ref_array[i];
      assign diff_right_quarter[i] = qpel[2*i] - ref_array[i];
    end
  endgenerate

  // Since there is no abs() in Verilog we have to implement
  function abs9;
    input  [8:0] in;

    begin
      if($signed(in)<0)
        abs9 = -$signed(in);
      else
        abs9 = in;
    end
  endfunction

  // Verilog doesn't have any sum() so we do this by hand too
  assign sad_array[4] = abs9(diff_left_quarter[1])+abs9(diff_left_quarter[2])+
                        abs9(diff_left_quarter[3])+abs9(diff_left_quarter[4])+
                        abs9(diff_left_quarter[5])+abs9(diff_left_quarter[6]);

  assign sad_array[3] = abs9(diff_left_half[1])+abs9(diff_left_half[2])+
                        abs9(diff_left_half[3])+abs9(diff_left_half[4])+
                        abs9(diff_left_half[5])+abs9(diff_left_half[6]);

  assign sad_array[2] = abs9(diff_full_pixel[1])+abs9(diff_full_pixel[2])+
                        abs9(diff_full_pixel[3])+abs9(diff_full_pixel[4])+
                        abs9(diff_full_pixel[5])+abs9(diff_full_pixel[6]);

  assign sad_array[1] = abs9(diff_right_half[1])+abs9(diff_right_half[2])+
                        abs9(diff_right_half[3])+abs9(diff_right_half[4])+
                        abs9(diff_right_half[5])+abs9(diff_right_half[6]);

  assign sad_array[0] = abs9(diff_right_quarter[1])+abs9(diff_right_quarter[2])+
                        abs9(diff_right_quarter[3])+abs9(diff_right_quarter[4])+
                        abs9(diff_right_quarter[5])+abs9(diff_right_quarter[6]);

endmodule
