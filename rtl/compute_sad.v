module compute_sad(cur_upper_pix, cur_middle_pix, cur_lower_pix,
                   org_pix, sad_uq, sad_uh, sad_middle, sad_lh, sad_lq);
  input [63:0] cur_upper_pix;
  input [63:0] cur_middle_pix;
  input [63:0] cur_lower_pix;
  input [63:0] org_pix;

  output [59:0] sad_uq;
  output [59:0] sad_uh;
  output [59:0] sad_middle;
  output [59:0] sad_lh;
  output [59:0] sad_lq;
  // 12 bits for each result sad the difference of each pixel is 9 bits wide
  // and there are 6 integers of 9 bits to add, thus we use 3 extra bits.

  // Follow the next diagram:
  // f   h q f q h   f <-- Index
  //
  // o   + + o + +   o <-- UF = Upper Full
  //
  // +   x x x x x   + <-- UH = Upper Half
  //     x x x x x     <-- UQ = Upper Quarter
  // o   x x o x x   o <-- M  = Middle
  //     x x x x x     <-- LQ = Lower Quarter
  // +   x x x x x   + <-- LH = Lower Half
  //
  // o   + + o + +   o <-- LF = Lower Full
  //
  // o --> Full pixel positions
  // x --> Fractional pixel positions
  // + --> Fractional pixel positions that are needed to calculate some 'x'


  wire [7:0]      filter_array[7:0];
  // Can't use vector as input, so we declare as a wire
  wire [7:0]      buffer_array[7:0];
  wire [7:0]      ref_array[7:0];
  wire [11:0]     sad_array[4:0];

  wire            UF_h[55:0];            
  wire            UF_q[111:0];

  wire            M_h[55:0];            
  wire            M_q[111:0];

  wire            LF_h[55:0];            
  wire            LF_q[111:0];

  filter_half    fh(cur_upper_pix,UF_h);
  filter_quarter fq(cur_upper_pix,UF_q);

  filter_half    fh(cur_middle_pix,M_h);
  filter_quarter fq(cur_middle_pix,M_q);

  filter_half    fh(cur_lower_pix,LF_h);
  filter_quarter fq(cur_lower_pix,LF_q);

  wire            UH_f[63:0];
  wire            LH_f[63:0];

  genvar          i;
  generate
    for(i=0;i<64;i+=8) begin
      UH_f[i+7:i] = (cur_upper_pix[i+7:i] + cur_middle_pix[i+7:i]) >> 1;
      LH_f[i+7:i] = (cur_lower_pix[i+7:i] + cur_middle_pix[i+7:i]) >> 1;
    end
  endgenerate

  wire            UH_h[55:0];
  wire            LH_h[55:0];

  generate
    for(i=0;i<56;i+=8) begin
      UH_h[i+7:i] = (UF_h[i+7:i] + M_h[i+7:i]) >> 1;
      LH_h[i+7:i] = (LF_h[i+7:i] + M_h[i+7:i]) >> 1;
    end
  endgenerate

  wire            UH_q[111:0];
  wire            LH_q[111:0];

  generate
    for(i=0;i<56;i+=8) begin
      UH_q[2*i+ 7:2*i  ] = (UH_f[i+ 7:i   ] + 3*UH_f[i+15:i+8]) >> 2;
      UH_q[2*i+15:2*i+8] = (UH_f[i+23:i+16] + 3*UH_f[i+15:i+8]) >> 2;

      LH_q[2*i+ 7:2*i  ] = (LH_f[i+ 7:i   ] + 3*LH_f[i+15:i+8]) >> 2;
      LH_q[2*i+15:2*i+8] = (LH_f[i+23:i+16] + 3*LH_f[i+15:i+8]) >> 2;
    end
  endgenerate

  wire            UQ_h[55:0];
  wire            LQ_h[55:0];
  wire            UQ_q[111:0];
  wire            LQ_q[111:0];

  generate
    for(i=0;i<56;i+=8) begin
      UQ_h[i+7:i] = (UF_h[i+7:i] + 3*M_h[i+7:i]) >> 2;
      LQ_h[i+7:i] = (LF_h[i+7:i] + 3*M_h[i+7:i]) >> 2;

      UQ_q[2*i+ 7:2*i  ] = (UF_q[2*i+ 7:2*i  ] + 3*M_q[2*i+ 7:2*i  ]) >> 2;
      UQ_q[2*i+15:2*i+8] = (UF_q[2*i+15:2*i+8] + 3*M_q[2*i+15:2*i+8]) >> 2;

      LQ_q[2*i+ 7:2*i  ] = (LF_q[2*i+ 7:2*i  ] + 3*M_q[2*i+ 7:2*i  ]) >> 2;
      LQ_q[2*i+15:2*i+8] = (LF_q[2*i+15:2*i+8] + 3*M_q[2*i+15:2*i+8]) >> 2;
    end
  endgenerate


/*
  generate
    for(i=1; i<=6; i=i+1) begin: abs_diff_generate
      abs_diff ad5(qpel[2*i-1],    ref_array[i], diff_left_quarter[i] );
      abs_diff ad4(hpel[i-1],      ref_array[i], diff_left_half[i]    );
      abs_diff ad3(filter_array[i],ref_array[i], diff_full_pixel[i]   );
      abs_diff ad2(hpel[i],        ref_array[i], diff_right_half[i]   );
      abs_diff ad1(qpel[2*i],      ref_array[i], diff_right_quarter[i]);
    end
  endgenerate






  assign {filter_array[7],filter_array[6],filter_array[5],filter_array[4],
          filter_array[3],filter_array[2],filter_array[1],filter_array[0]} = filter_pix;

  assign {buffer_array[7],buffer_array[6],buffer_array[5],buffer_array[4],
          buffer_array[3],buffer_array[2],buffer_array[1],buffer_array[0]} = buffer_pix;

  assign {ref_array[7],ref_array[6],ref_array[5],ref_array[4],
          ref_array[3],ref_array[2],ref_array[1],ref_array[0]} = ref_pix;

  assign sad = {sad_array[4],sad_array[3],sad_array[2],sad_array[1],sad_array[0]};

  wire [7:0]      hpel[6:0];
  wire [7:0]      qpel[13:0];
  wire [7:0]      hpelu[6:0];
  wire [7:0]      qpelu[13:0];

  wire [7:0]      hpelh[6:0];
  wire [7:0]      qpelh[13:0];
  wire [7:0]      hpelq[6:0];
  wire [7:0]      qpelq[13:0];

  generate
    for(i=0; i<=6; i=i+1) begin: hpel_generate
      assign hpel[i] = (filter_array[i] + filter_array[i+1])/2;
      // The resulting sum is 9 bit, but the division will bring the total back to 8
      // TODO: Must test to see if synthesizer will do this right using 255 as input

      assign qpel[2*i]   = (3*filter_array[i] +   filter_array[i+1])/4;
      assign qpel[2*i+1] = (  filter_array[i] + 3*filter_array[i+1])/4;
      // Same here but the rounding is 10 bit to 8
      // TODO: Also test for the extreme cases in syntesizer

      assign hpelu[i]    = (  buffer_array[i] +   buffer_array[i+1])/2;
      assign qpelu[2*i]  = (3*buffer_array[i] +   buffer_array[i+1])/4;
      assign qpelu[2*i+1]= (  buffer_array[i] + 3*buffer_array[i+1])/4;

      assign hpelh[i]    = (  buffer_array[i] +   filter_array[i])/2;
      assign hpelq[i]    = (  buffer_array[i] + 3*filter_array[i])/4;

//      assign qpelh[2*i]  = ();
    end

  endgenerate

  // Each diff must contain one extra bit because the result lies in [-255..255]
  wire [7:0] diff_left_quarter[6:1];
  wire [7:0] diff_left_half[6:1];
  wire [7:0] diff_full_pixel[6:1];
  wire [7:0] diff_right_half[6:1];
  wire [7:0] diff_right_quarter[6:1];

  generate
    for(i=1; i<=6; i=i+1) begin: abs_diff_generate
      abs_diff ad5(qpel[2*i-1],    ref_array[i], diff_left_quarter[i] );
      abs_diff ad4(hpel[i-1],      ref_array[i], diff_left_half[i]    );
      abs_diff ad3(filter_array[i],ref_array[i], diff_full_pixel[i]   );
      abs_diff ad2(hpel[i],        ref_array[i], diff_right_half[i]   );
      abs_diff ad1(qpel[2*i],      ref_array[i], diff_right_quarter[i]);
    end
  endgenerate

  // Verilog doesn't have any sum() so we do this by hand too
  assign sad_array[4] = diff_left_quarter[1]+diff_left_quarter[2]+
                        diff_left_quarter[3]+diff_left_quarter[4]+
                        diff_left_quarter[5]+diff_left_quarter[6];

  assign sad_array[3] = diff_left_half[1]+diff_left_half[2]+
                        diff_left_half[3]+diff_left_half[4]+
                        diff_left_half[5]+diff_left_half[6];

  assign sad_array[2] = diff_full_pixel[1]+diff_full_pixel[2]+
                        diff_full_pixel[3]+diff_full_pixel[4]+
                        diff_full_pixel[5]+diff_full_pixel[6];

  assign sad_array[1] = diff_right_half[1]+diff_right_half[2]+
                        diff_right_half[3]+diff_right_half[4]+
                        diff_right_half[5]+diff_right_half[6];

  assign sad_array[0] = diff_right_quarter[1]+diff_right_quarter[2]+
                        diff_right_quarter[3]+diff_right_quarter[4]+
                        diff_right_quarter[5]+diff_right_quarter[6];
*/
endmodule
