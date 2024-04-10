// File: soundgen.sv
// Description: creates a sound when a food is eaten, or when gameover
// Author: Kento Sasaki 
// Date: 2024-04-02

module soundgen
(
    output logic spkr,  // speaker output
    input logic reset_n,
    input logic food_eaten, // input signal for when food is eaten
    input logic game_over, // input signal for when user loses
    input logic clk
);  // reset and clock

  parameter [0:2][31:0] FOOD_NOTES = {32'd262, 32'd349, 32'd491};
  parameter [0:2][31:0] GAMEOVER_NOTES = {32'd491, 32'd349, 32'd262};

  logic food_eaten_prev;  // used to see rising edge of the food_eaten pulse
  logic game_over_prev;   // used to see rising edge of the game_over pulse

  logic [31:0] count;
  logic [31:0] freq;

  logic [0:2][31:0] notes; // note what will be played

  freqgen #(50_000_000) freqgen_0 (
        .freq(freq),
        .out_clk(spkr),
        .reset_n,
        .clk(clk)
    );

  // Define states
  typedef enum logic [1:0] {
    IDLE,
    FIRST_NOTE,
    SECOND_NOTE,
    THIRD_NOTE
  } state_t;
  state_t state = IDLE, next_state; // state machine variables

  always @(posedge clk) begin
    if (~reset_n) begin
      count <= 0;
      freq <= 0;
      state <= IDLE;
      food_eaten_prev <= 0;
      game_over_prev <= 0;
    end else begin
      case(state)
        IDLE : begin
          freq <= 0;
          count <= 0;
          if(food_eaten & ~food_eaten_prev) begin
            // loads the food notes to be played and go to FIRST_NOTE state
            notes <= FOOD_NOTES;
            state <= next_state;
          end
          else if (game_over & ~game_over_prev) begin
            // loads the game over notes to be played and go to FIRST_NOTE state
            notes <= GAMEOVER_NOTES;
            state <= next_state;
          end
        end
        FIRST_NOTE : begin
          if(count < 5_000_000) begin
            // play note for 100ms
            freq <= notes[0];
            count <= count + 1;
          end
          else begin
            // go to SECOND_NOTE state
            state <= next_state;
            count <= 0;
          end 
        end
        SECOND_NOTE : begin
          if(count < 5_000_000) begin
            freq <= notes[1];
            count <= count + 1;
          end
          else begin
            // go to THIRD_NOTE state
            state <= next_state;
            count <= 0;
          end 
        end
        THIRD_NOTE : begin
          if(count < 5_000_000) begin
            freq <= notes[2];
            count <= count + 1;
          end
          else begin
            // stop playing notes
            state <= next_state;
            count <= 0;
          end 
        end
      endcase
    end
  food_eaten_prev <= food_eaten;
  game_over_prev <= game_over;
  end

  // next_state logic for state machine
  always_comb begin
    case (state)
      IDLE: next_state = FIRST_NOTE;
      FIRST_NOTE: next_state = SECOND_NOTE;
      SECOND_NOTE: next_state = THIRD_NOTE;
      THIRD_NOTE: next_state = IDLE;
    endcase
  end

endmodule

