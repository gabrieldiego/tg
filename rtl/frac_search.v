module frac_search(filter_pix, ref_pix, input_ready, sad_out, clk, reset);
  input [63:0] filter_pix;
  input [55:8] ref_pix;
  input        input_ready;
  output [59:0] sad_out;

  input clk, reset;

  wire [63:0] filter_pix;
  wire [55:8] ref_pix;

  wire clk, reset;

  reg [63:0] buffer_pix;
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

  wire [59:0] sad_out;
  reg  [9:0] sad_buffer[5:0];
  reg  [9:0] sad_sum[5:0];
  reg  [9:0] sad_min[4:0];
  reg  [2:0] vec_min[4:0];

  compute_sad cs(filter_pix, buffer_pix, ref_pix, input_ready, sad_out);

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
      buffer_pix <= filter_pix;
      for(i=0; i<=5; i=i+1 ) begin  
        sad_buffer[i] <= sad_sum[i];
      end
    end

  always @(*) begin
    case(state)
      IDLE: begin
        pix_counter <= 0;

        if(input_ready)
          next_state <= RECV;
        else
          next_state <= IDLE;
      end
      RECV: begin
        if(input_ready) begin
          pix_counter <= pix_counter+1;
          next_state <= IDLE;
		  end
        else begin
          next_state <= RECV;
        end
      end
    endcase
  end

endmodule
