module frac_search(cur_pix, org_pix, ready, sad_out, mvx, mvy, clk, reset);
  input [63:0]  cur_pix;
  input [55:8]  org_pix;
  input         ready;

  output [11:0] sad_out;
  output [2:0]  mvx;
  output [2:0]  mvy;

  input         clk, reset;

  // The idea here is to perform the QPEL mv search in a 8x8 block
  //  using only the current 8x8 block and the original 8x8 block.
  // This reduces greatly the number of taps and does not require padding.
  // Thus this will be only two states:
  //  - IDLE: Obvious
  //  - RECV: 8 cycles to receive each line of both blocks
  // The result will be displayed the next cycle after it finishes receiving
  //  the blocks
  //
  // Remember to insert the org_pix lines with two cycle delay since we need
  //  to buffer the cur lines in order to allow the filter to have the upper
  //  and the lower lines. Also keep in mind that the first line is not needed.
  //  You should input only the second through the senventh line.
  //
  // One example of input is this (@posedge clk):
  //
  //  ready | cur_pix | org_pix | state | counter
  //    0   |    X    |    X    |  IDLE |    0
  //    1   |   1st   |    X    |  IDLE |    0
  //    1   |   2nd   |    X    |  RECV |    1
  //    1   |   3rd   |   2nd   |  RECV |    2
  //    1   |   4th   |   3rd   |  RECV |    3
  //    1   |   5th   |   4th   |  RECV |    4
  //    1   |   6th   |   5th   |  RECV |    5
  //    1   |   7th   |   6th   |  RECV |    6
  //    1   |   8th   |   7th   |  RECV |    7
  //    X   |    X    |    X    |  RSLT |    0  --> mvx, mvy with results
  //    0   |    X    |    X    |  IDLE |    0

  reg  [63:0]   cur_upper_pix;
  reg  [63:0]   cur_middle_pix;
  reg  [63:0]   cur_lower_pix;
  reg  [55:8]   org_pix_reg;
  // It is important to register the inputs since they may be vary

  reg  [2:0]    counter;

  reg  [1:0]    state,next_state;
  parameter     IDLE = 0,
                RECV = 1,
                RSLT = 2;

  wire [59:0]   line_sad_UH;
  wire [59:0]   line_sad_UQ;
  wire [59:0]   line_sad_M;
  wire [59:0]   line_sad_LQ;
  wire [59:0]   line_sad_LH;

  reg  [13:0]   sad_UH[4:0];
  reg  [13:0]   sad_UQ[4:0];
  reg  [13:0]   sad_M[4:0];
  reg  [13:0]   sad_LQ[4:0];
  reg  [13:0]   sad_LH[4:0];

  wire [13:0]   next_sad_UH[4:0];
  wire [13:0]   next_sad_UQ[4:0];
  wire [13:0]   next_sad_M[4:0];
  wire [13:0]   next_sad_LQ[4:0];
  wire [13:0]   next_sad_LH[4:0];

  wire [69:0]   sad_UH_vec;
  wire [69:0]   sad_UQ_vec;
  wire [69:0]   sad_M_vec;
  wire [69:0]   sad_LQ_vec;
  wire [69:0]   sad_LH_vec;

  wire [69:0]   smallest_sad_vec;
  wire [13:0]   smallest_sad_ver;
  wire [2:0]    idx_min[4:0];
  wire [2:0]    idx_min_ver;    

  integer       i;

  compute_sad cs(cur_upper_pix, cur_middle_pix, cur_lower_pix, org_pix_reg,
       line_sad_UH, line_sad_UQ, line_sad_M, line_sad_LQ, line_sad_LH);

  assign sad_UH_vec = {next_sad_UH[4], next_sad_UH[3], next_sad_UH[2], next_sad_UH[1], next_sad_UH[0]};
  assign sad_UQ_vec = {next_sad_UQ[4], next_sad_UQ[3], next_sad_UQ[2], next_sad_UQ[1], next_sad_UQ[0]};
  assign sad_M_vec  = {next_sad_M[4] , next_sad_M[3] , next_sad_M[2] , next_sad_M[1] , next_sad_M[0] };
  assign sad_LQ_vec = {next_sad_LQ[4], next_sad_LQ[3], next_sad_LQ[2], next_sad_LQ[1], next_sad_LQ[0]};
  assign sad_LH_vec = {next_sad_LH[4], next_sad_LH[3], next_sad_LH[2], next_sad_LH[1], next_sad_LH[0]};

  smallest_sad ss_UH(sad_UH_vec,smallest_sad_vec[13: 0],idx_min[0]);
  smallest_sad ss_UQ(sad_UQ_vec,smallest_sad_vec[27:14],idx_min[1]);
  smallest_sad ss_M (sad_M_vec ,smallest_sad_vec[41:28],idx_min[2]);
  smallest_sad ss_LQ(sad_LQ_vec,smallest_sad_vec[55:42],idx_min[3]);
  smallest_sad ss_LH(sad_LH_vec,smallest_sad_vec[69:56],idx_min[4]);

  smallest_sad ss_VER(smallest_sad_vec,smallest_sad_ver,idx_min_ver);

  assign mvy     = idx_min_ver;
  assign mvx     = idx_min[idx_min_ver];
  assign sad_out = smallest_sad_ver;

  assign next_sad_UH[4] = sad_UH[4] + line_sad_UH[59:48];
  assign next_sad_UH[3] = sad_UH[3] + line_sad_UH[47:36];
  assign next_sad_UH[2] = sad_UH[2] + line_sad_UH[35:24];
  assign next_sad_UH[1] = sad_UH[1] + line_sad_UH[23:12];
  assign next_sad_UH[0] = sad_UH[0] + line_sad_UH[11: 0];

  assign next_sad_UQ[4] = sad_UQ[4] + line_sad_UQ[59:48];
  assign next_sad_UQ[3] = sad_UQ[3] + line_sad_UQ[47:36];
  assign next_sad_UQ[2] = sad_UQ[2] + line_sad_UQ[35:24];
  assign next_sad_UQ[1] = sad_UQ[1] + line_sad_UQ[23:12];
  assign next_sad_UQ[0] = sad_UQ[0] + line_sad_UQ[11: 0];

  assign next_sad_M[4]  = sad_M[4]  + line_sad_M[59:48];
  assign next_sad_M[3]  = sad_M[3]  + line_sad_M[47:36];
  assign next_sad_M[2]  = sad_M[2]  + line_sad_M[35:24];
  assign next_sad_M[1]  = sad_M[1]  + line_sad_M[23:12];
  assign next_sad_M[0]  = sad_M[0]  + line_sad_M[11: 0];

  assign next_sad_LQ[4] = sad_LQ[4] + line_sad_LQ[59:48];
  assign next_sad_LQ[3] = sad_LQ[3] + line_sad_LQ[47:36];
  assign next_sad_LQ[2] = sad_LQ[2] + line_sad_LQ[35:24];
  assign next_sad_LQ[1] = sad_LQ[1] + line_sad_LQ[23:12];
  assign next_sad_LQ[0] = sad_LQ[0] + line_sad_LQ[11: 0];

  assign next_sad_LH[4] = sad_LH[4] + line_sad_LH[59:48];
  assign next_sad_LH[3] = sad_LH[3] + line_sad_LH[47:36];
  assign next_sad_LH[2] = sad_LH[2] + line_sad_LH[35:24];
  assign next_sad_LH[1] = sad_LH[1] + line_sad_LH[23:12];
  assign next_sad_LH[0] = sad_LH[0] + line_sad_LH[11: 0];


  always @(posedge clk or posedge reset)
    if (reset == 1'b1) begin
      state <= IDLE;
      for(i=0; i<5; i=i+1 ) begin
        sad_UH[i] = 0;
        sad_UQ[i] = 0;
        sad_M [i] = 0;
        sad_LQ[i] = 0;
        sad_LH[i] = 0;
      end
    end
    else begin
      state = next_state;

      if(state == IDLE) begin
        cur_lower_pix  = cur_pix;
        counter        = 0;
      end

      if((state == RECV && ready) || state == RSLT) begin
        cur_upper_pix  = cur_middle_pix;
        cur_middle_pix = cur_lower_pix;
        cur_lower_pix  = cur_pix;
        org_pix_reg    = org_pix;
        counter        = counter + 1;
      end

      if((state == RECV && ready && counter > 3) || state == RSLT) begin
        sad_UH[4] = next_sad_UH[4];
        sad_UH[3] = next_sad_UH[3];
        sad_UH[2] = next_sad_UH[2];
        sad_UH[1] = next_sad_UH[1];
        sad_UH[0] = next_sad_UH[0];

        sad_UQ[4] = next_sad_UQ[4];
        sad_UQ[3] = next_sad_UQ[3];
        sad_UQ[2] = next_sad_UQ[2];
        sad_UQ[1] = next_sad_UQ[1];
        sad_UQ[0] = next_sad_UQ[0];

        sad_M[4]  = next_sad_M[4];
        sad_M[3]  = next_sad_M[3];
        sad_M[2]  = next_sad_M[2];
        sad_M[1]  = next_sad_M[1];
        sad_M[0]  = next_sad_M[0];

        sad_LQ[4] = next_sad_LQ[4];
        sad_LQ[3] = next_sad_LQ[3];
        sad_LQ[2] = next_sad_LQ[2];
        sad_LQ[1] = next_sad_LQ[1];
        sad_LQ[0] = next_sad_LQ[0];

        sad_LH[4] = next_sad_LH[4];
        sad_LH[3] = next_sad_LH[3];
        sad_LH[2] = next_sad_LH[2];
        sad_LH[1] = next_sad_LH[1];
        sad_LH[0] = next_sad_LH[0];
      end
      else begin
        sad_UH[4] = 0;
        sad_UH[3] = 0;
        sad_UH[2] = 0;
        sad_UH[1] = 0;
        sad_UH[0] = 0;

        sad_UQ[4] = 0;
        sad_UQ[3] = 0;
        sad_UQ[2] = 0;
        sad_UQ[1] = 0;
        sad_UQ[0] = 0;

        sad_M[4]  = 0;
        sad_M[3]  = 0;
        sad_M[2]  = 0;
        sad_M[1]  = 0;
        sad_M[0]  = 0;

        sad_LQ[4] = 0;
        sad_LQ[3] = 0;
        sad_LQ[2] = 0;
        sad_LQ[1] = 0;
        sad_LQ[0] = 0;

        sad_LH[4] = 0;
        sad_LH[3] = 0;
        sad_LH[2] = 0;
        sad_LH[1] = 0;
        sad_LH[0] = 0;
      end
  end

  always @(*) begin
    case(state)
      IDLE: begin
        if(ready)
          next_state <= RECV;
        else
          next_state <= IDLE;
      end
      RECV: begin
        if(counter == 7) begin
          next_state <= RSLT;
		end
        else begin
          next_state <= RECV;
        end
      end
      RSLT: begin
        next_state <= IDLE;
      end
    endcase
  end

endmodule
