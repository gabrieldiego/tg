module compute_sad(cur_upper_pix, cur_middle_pix, cur_lower_pix, org_pix,
                   sad_UH, sad_UQ, sad_M, sad_LQ, sad_LH);
  input [63:0] cur_upper_pix;
  input [63:0] cur_middle_pix;
  input [63:0] cur_lower_pix;
  input [63:0] org_pix;

  output [59:0] sad_UH;
  output [59:0] sad_UQ;
  output [59:0] sad_M;
  output [59:0] sad_LQ;
  output [59:0] sad_LH;

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

  abs_diff_line  abl(cur_upper_pix, cur_middle_pix ,cur_lower_pix, org_pix,
                     diff_UH_h, diff_UH_q, diff_UH_f, diff_UH_r, diff_UH_i,
                     diff_UQ_h, diff_UQ_q, diff_UQ_f, diff_UQ_r, diff_UQ_i,
                     diff_M_h , diff_M_q , diff_M_f , diff_M_r , diff_M_i ,
                     diff_LQ_h, diff_LQ_q, diff_LQ_f, diff_LQ_r, diff_LQ_i,
                     diff_LH_h, diff_LH_q, diff_LH_f, diff_LH_r, diff_LH_i);

  sad csad_UH(diff_UH_h, diff_UH_q, diff_UH_f, diff_UH_r, diff_UH_i, sad_UH);
  sad csad_UQ(diff_UQ_h, diff_UQ_q, diff_UQ_f, diff_UQ_r, diff_UQ_i, sad_UQ);
  sad csad_M (diff_M_h , diff_M_q , diff_M_f , diff_M_r , diff_M_i , sad_M );
  sad csad_LQ(diff_LQ_h, diff_LQ_q, diff_LQ_f, diff_LQ_r, diff_LQ_i, sad_LQ);
  sad csad_LH(diff_LH_h, diff_LH_q, diff_LH_f, diff_LH_r, diff_LH_i, sad_LH);

endmodule
