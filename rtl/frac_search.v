module frac_search(filter_pix, ref_pix, input_ready, mvx, mvy, clk, reset);
  input [63:0] filter_pix;
  input [63:0] ref_pix;
  input        input_ready;
  output [2:0] mvx, mvy;

  input clk, reset;

  wire [63:0] filter_pix;
  wire [63:0] ref_pix;
  reg  [2:0] mvx, mvy;

  wire clk, reset;

  reg [63:0] pix_buffer;
  reg [2:0] pix_counter;

  reg       state,next_state;
  parameter IDLE = 0,
            RECV = 1;

  /*
     The idea here is to perform the QPEL mv search in a 8x8 block
      using only the reference 8x8 block and a 8x8 block to be filtered.
     This reduces greatly the number of taps and does not require padding.
     Thus there will be only two states:
     -IDLE: Obvious
     -RECV: 8 cycles to receive each line of both blocks
     The result will be displayed the next cycle after it finishes receiving the 
     blocks
   */

  wire [7:0] filter_array[7:0]; // Can't use vector as input, so we declare as a wire
  wire [7:0] ref_array[7:0];

  wire [59:0] sad;
  reg  [9:0] sad_buffer[5:0];
  reg  [9:0] sad_sum[5:0];

  compute_sad cs(filter_pix, ref_pix, input_ready, sad);

  assign {filter_array[7],filter_array[6],filter_array[5],
          filter_array[4],filter_array[3],filter_array[2],
          filter_array[1],filter_array[0]} = filter_pix;

  assign {ref_array[7],ref_array[6],ref_array[5],ref_array[4],
          ref_array[3],ref_array[2],ref_array[1],ref_array[0]} = ref_pix;

  integer   i;

  always @(posedge clk or posedge reset)
    if (reset == 1'b1) begin
      state <= IDLE;
      for(i=0; i<=5; i=i+1 ) begin  
        sad_buffer[i] <= 0;
      end
    end
    else begin
      state <= next_state;
      pix_buffer <= filter_pix;
      for(i=0; i<=5; i=i+1 ) begin  
        sad_buffer[i] <= sad_sum[i];
      end
    end

  always @(*) begin
    case(state)
      IDLE: begin
        mvx <= 0;
        mvy <= 0;
        pix_buffer <= filter_pix;
        pix_counter <= 0;

        if(input_ready)
          next_state <= RECV;
        else
          next_state <= IDLE;
      end
      RECV: begin
        mvx <= pix_counter[2:0];
        mvy <= pix_counter[2:0]+2;

        if(input_ready) begin

          pix_counter <= pix_counter+1;

          for(i=0; i<=5; i=i+1 ) begin
            sad_sum[i] <= sad_sum[i] + sad_buffer[i];
          end

          if(pix_counter == 8'hF)
            next_state <= IDLE;
          else
            next_state <= RECV;
        end
      end
    endcase
  end

endmodule
