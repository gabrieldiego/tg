module smallest_sad(sad_vec, smallest_sad, smallest_idx);
  input  [69:0] sad_vec;
  output [13:0] smallest_sad;
  output  [2:0] smallest_idx;

  wire   [13:0] smallest_sad_1;
  wire   [13:0] smallest_sad_2;
  wire   [13:0] smallest_sad_3;

  wire    [2:0] smallest_idx_1;
  wire    [2:0] smallest_idx_2;
  wire    [2:0] smallest_idx_3;

  assign smallest_sad_1 = sad_vec[13: 0] < sad_vec[27:14] ?
                          sad_vec[13: 0] : sad_vec[27:14];
  assign smallest_idx_1 = sad_vec[13: 0] < sad_vec[27:14] ? 0 : 1;

  assign smallest_sad_2 = sad_vec[41:28] < sad_vec[55:42] ?
                          sad_vec[41:28] : sad_vec[55:42];
  assign smallest_idx_2 = sad_vec[41:28] < sad_vec[55:42] ? 2 : 3;


  assign smallest_sad_3 = sad_vec[69:56] < smallest_sad_1 ?
                          sad_vec[69:56] : smallest_sad_1;
  assign smallest_idx_3 = sad_vec[69:56] < smallest_sad_1 ? 3 : smallest_idx_1;

  assign smallest_sad   = smallest_sad_2 < smallest_sad_3 ?
                          smallest_sad_2 : smallest_sad_3;
  assign smallest_idx   = smallest_sad_2 < smallest_sad_3 ?
                          smallest_idx_2 : smallest_idx_3;

endmodule
