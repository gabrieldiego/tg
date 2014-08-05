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

  reg  [2:0]    mvx;
  reg  [2:0]    mvy;

  reg  [63:0]   cur_upper_pix;
  reg  [63:0]   cur_middle_pix;
  reg  [63:0]   cur_lower_pix;

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

  reg  [9:0]    sad_min[4:0];
  reg  [2:0]    vec_min[4:0];

  integer       i;

  compute_sad cs(cur_upper_pix, cur_middle_pix, cur_lower_pix, org_pix,
       line_sad_UH, line_sad_UQ, line_sad_M, line_sad_LQ, line_sad_LH);

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

      case(state)
        IDLE: begin
          cur_lower_pix  = cur_pix;
          counter        = 0;
        end
        RECV: begin
          if(ready) begin
            cur_upper_pix  = cur_middle_pix;
            cur_middle_pix = cur_lower_pix;
            cur_lower_pix  = cur_pix;
            counter        = counter + 1;
            if(counter >= 2) begin
              sad_M[4] = sad_M[4] + line_sad_M[59:48]; // FIXME: Implement the sum for all lines
              sad_M[3] = sad_M[3] + line_sad_M[47:36];
              sad_M[2] = sad_M[2] + line_sad_M[35:24];
              sad_M[1] = sad_M[1] + line_sad_M[23:12];
              sad_M[0] = sad_M[0] + line_sad_M[11: 0];
            end
          end
        end
        RSLT: begin
          counter        = 0;
          if(sad_M[4]<sad_M[3]) begin
            mvx <= 1; // FIXME: Implement the smallest selector
          end
          else begin
            mvx <= 0;
          end
        end
      endcase
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
