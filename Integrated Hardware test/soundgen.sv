// File: soundgen.sv
// Description: creates a sound when a food is eaten, or when gameover
// Author: Kento Sasaki 
// Date: 2024-04-02

module soundgen #(
    parameter FCLK
)  // clock frequency, Hz
(
    output logic spkr,  // speaker output
    input logic reset_n,
    input logic food_eaten,
    input logic game_over,
    input logic clk
);  // reset and clock

  parameter [31:0][1:0] FOOD_NOTES = 32'd;

  logic [31:0] count;
  logic [31:0] freq;

  tonegen #(50_000_000) freqgen_0 (
        .freq(freq),
        .onOff(s1),
        .spkr(spkr),
        .reset_n(s2),
        .clk(clk)
    );

  // Define states
  typedef enum logic [1:0] {
    IDLE,
    FIRST_NOTE,
    SECOND_NOTE,
    THIRD_NOTE
  } state_t;
  state_t state = IDLE, next_state;

  always @(posedge clk) begin

    if (~reset_n) begin
      count <= 0;
    end else begin
      case(state)
        IDLE : begin
          if(food_eaten)

        end
        FIRST_NOTE : begin

        end
        SECOND_NOTE : begin

        end
        THIRD_NOTE : begin

        end
      endcase
    end

  end

  always_comb begin
    case (state)
      IDLE: next_state = FIRST_NOTE;
      FIRST_NOTE: next_state = SECOND_NOTE;
      SECOND_NOTE: next_state = THIRD_NOTE;
      THIRD_NOTE: next_state = IDLE;
    endcase
  end

endmodule

