module sad(diff_h, diff_q, diff_f, diff_r, diff_i, sad_vector);
  input  [47:0] diff_h, diff_q, diff_f, diff_r, diff_i;
  output [59:0] sad_vector;


  assign sad_vector[11 :0] = diff_h[ 7: 0] + diff_h[15: 8] + diff_h[23:16]+
                             diff_h[31:24] + diff_h[39:32] + diff_h[47:40];

  assign sad_vector[23:12] = diff_q[ 7: 0] + diff_q[15: 8] + diff_q[23:16] +
                             diff_q[31:24] + diff_q[39:32] + diff_q[47:40];

  assign sad_vector[35:24] = diff_f[ 7: 0] + diff_f[15: 8] + diff_f[23:16] +
                             diff_f[31:24] + diff_f[39:32] + diff_f[47:40];

  assign sad_vector[47:36] = diff_r[ 7: 0] + diff_r[15: 8] + diff_r[23:16] +
                             diff_r[31:24] + diff_r[39:32] + diff_r[47:40];

  assign sad_vector[59:48] = diff_i[ 7: 0] + diff_i[15: 8] + diff_i[23:16] +
                             diff_i[31:24] + diff_i[39:32] + diff_i[47:40];

endmodule
