// File: Snake.sv
// Description: Snakegame top level module that connects submodules together
// Author: Bryce Adam & Kento Sasaki
// Date: 2024-04-09

module Snake (
    input logic CLOCK_50,  // 50 MHz clock
    input logic reset_n,
    output logic [7:0] leds,  // 7-seg LED enables
    output logic [3:0] ct,
    output logic led_din, led_cs, led_clk,
    input logic ir_signal,
    output logic red, green, blue,  // RGB LED signals
    output logic spkr
);  // digit cathodes

  // Define states
  typedef enum logic [1:0] {
    START_SCREEN,
    GAME_SCREEN,
    END_SCREEN
  } state_t;
  state_t state = START_SCREEN, next_state; // state machine variables

  logic [1:0] digit;  // select digit to display
  logic [3:0] disp_digit;  // current digit of count to display
  logic [15:0] clk_div_count;  // count used to divide clock
  logic [4:0] led_clk_div_count;  // count used to divide clock for led matrix

  logic [15:0][15:0] grid;  // Tells MatrixDisplay which LEDs to illuminate
  logic [255:0][7:0] positions; // Stores the snake's head and body positions

  logic [31:0] word;  // word from the ir reciever
  logic [7:0] length; // length of the snake
  logic [11:0] score;
  logic [7:0] foodPos; 
  logic [2:0] difficulty = 3'd4; // Sets the game speed

  logic game_over;      // pulses high when you lose
  logic food_eaten;     // pulses high when you eat snake food

  logic game_enable;    // enables the game to run

  logic [15:0] grid_row;
  logic [15:0] grid_col;

  logic [15:0][15:0] disp_grid;

  logic slow_clk; // Slower clock given to the led matrix
  logic game_clk; // Slower clock given to the game
  logic nec_clk; // Clock given to the ir_reciever

  // Clocks of each difficulty
  logic game_clk1, game_clk2, game_clk3, game_clk4, game_clk5, game_clk6;

  // Codes for each button press we will use
  parameter [31:0] UP = 32'h20DF6A95;
  parameter [31:0] DOWN = 32'h20DFEA15;
  parameter [31:0] LEFT = 32'h20DF1AE5;
  parameter [31:0] RIGHT = 32'h20DF9A65;
  parameter [31:0] ENTER = 32'h20DF5AA5;
  parameter [31:0] MENU = 32'h20DFC23D;
  parameter [15:0] ONE = 16'h8877;
  parameter [31:0] TWO = 32'h20DF48B7;
  parameter [31:0] THREE = 32'h20DFC837;
  parameter [31:0] FOUR = 32'h20DF28D7;
  parameter [31:0] FIVE = 32'h20DFA857;
  parameter [31:0] SIX = 32'h20DF6897;

  // start message
  logic [0:15][0:15] START_GRID = {
    16'b0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_1_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_1_1_1_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_1_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_1_1_1_1_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b1_1_0_1_0_0_1_0_1_0_1_0_1_0_1_0,
    16'b0_1_0_1_0_1_1_0_1_1_1_0_1_0_1_0,
    16'b1_0_0_1_1_0_1_0_1_0_1_0_1_1_0_0,
    16'b1_1_0_1_0_0_1_0_0_1_0_0_1_0_1_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
  };
  // end message
  logic [0:15][0:15] END_GRID = {
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_1_1_1_0_1_0_0_1_0_1_1_1_0_0_0,
    16'b0_1_0_0_0_1_0_0_1_0_1_0_0_1_0_0,
    16'b0_1_1_1_0_1_0_1_1_0_1_0_0_1_0_0,
    16'b0_1_0_0_0_1_1_0_1_0_1_0_0_1_0_0,
    16'b0_1_1_1_0_1_0_0_1_0_1_1_1_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0,
    16'b0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0
  };


  // instantiate modules to implement design
  decode2 decode2_0 (
      .digit,
      .ct
  );
  decode7 decode7_0 (
      .num(disp_digit),
      .leds
  );


  freqgen #(50_000_000) ir_freqgen_1 (.out_clk(game_clk1), .reset_n, .clk(CLOCK_50), .freq(2)); // Generate game clock1
  freqgen #(50_000_000) ir_freqgen_2 (.out_clk(game_clk2), .reset_n, .clk(CLOCK_50), .freq(4)); // Generate game clock2
  freqgen #(50_000_000) ir_freqgen_3 (.out_clk(game_clk3), .reset_n, .clk(CLOCK_50), .freq(6)); // Generate game clock3
  freqgen #(50_000_000) ir_freqgen_4 (.out_clk(game_clk4), .reset_n, .clk(CLOCK_50), .freq(8)); // Generate game clock4
  freqgen #(50_000_000) ir_freqgen_5 (.out_clk(game_clk5), .reset_n, .clk(CLOCK_50), .freq(10)); // Generate game clock5
  freqgen #(50_000_000) ir_freqgen_6 (.out_clk(game_clk6), .reset_n, .clk(CLOCK_50), .freq(12)); // Generate game clock6
  freqgen #(50_000_000) ir_freqgen_0 (.out_clk(nec_clk), .reset_n, .clk(CLOCK_50), .freq(17_778));  // Generate irReceiver clock
  irReceiver irReceiver_0 (.ir_signal, .nec_clk, .word, .reset_n);                                // converts encoded ir signal into bits
  snakegame snakegame_0 (.direction(word), .game_clk, .reset_n, .positions, .length, .foodPos, .food_eaten, .game_over, .game_enable); // main game's logic
  MatrixDisplay MatrixDisplay_0 (.clk(slow_clk), .reset_n, .grid(disp_grid), .DIN(led_din), .CS(led_cs), .LED_CLK(led_clk));
  pos2grid pos2grid_0 (.pos(positions), .length, .foodPos, .grid_row, .grid_col);
  soundgen soundgen_0 (.spkr, .clk(CLOCK_50), .reset_n, .food_eaten, .game_over);

  // Clock dividing logic for the matrix display
  always_ff @(posedge CLOCK_50) led_clk_div_count <= led_clk_div_count + 1'b1;

  // assign the top bit of clk_div_count as the led clock
  assign slow_clk = led_clk_div_count[4];

  // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
  always_ff @(posedge CLOCK_50) clk_div_count <= clk_div_count + 1'b1;

  // assign the top two bits of count to select digit to display
  assign digit = clk_div_count[15:14];

  always_ff @(posedge CLOCK_50) begin
    grid[grid_row] <= grid_col;
    grid_row <= grid_row + 1;
  end

  always_ff @(posedge CLOCK_50) begin
    case (state)
      START_SCREEN: begin           // starts and waits in START_SCREEN state
        if (word == ENTER) begin
          // if received button is ENTER, go to GAME_SCREEN state
          state <= next_state;
			    game_enable <= 1;
        end
        else if(word[15:0] == ONE)
            difficulty <= 1;
        else if(word == TWO)
            difficulty <= 2;
        else if(word == THREE)
            difficulty <= 3;
        else if(word == FOUR)
            difficulty <= 4;
        else if(word == FIVE)
            difficulty <= 5;
        else if(word == SIX)
            difficulty <= 6;
        else begin
          disp_grid <= START_GRID; // displays the start grid
          game_enable <= 0;
        end
      end
      GAME_SCREEN: begin
        // waits for game_over signal
        if (game_over) begin
          // disable the game and go to END_SCREEN state
          state <= next_state;
          game_enable <= 0;
        end
        else begin
          disp_grid <= grid; // displays the snake game grid
        end
      end
      END_SCREEN : begin
        if(word == MENU) begin
          // if received button is MENU, go back to START_SCREEN state
          state <= next_state;
          game_enable <= 0;
        end else begin
          disp_grid <= END_GRID; // displays the end grid
        end
      end

    endcase
  end

  // displays the game difficulty on the MSD side, shows the current game score on the right LSD
  always_comb begin
    bit [3:0] nibble[4];
    nibble[0]  <= difficulty;
    nibble[1]  <= score[11:8];
    nibble[2]  <= score[7:4];
    nibble[3]  <= score[3:0];

    disp_digit <= nibble[digit];
  end
  
  assign score = length * 5 - 5; // score multiplier based on snake length

  assign {red, green, blue} = '0;

  // next state logic
  always_comb begin
    case (state)
      START_SCREEN: next_state = GAME_SCREEN;
      GAME_SCREEN: next_state = END_SCREEN;
      END_SCREEN: next_state = START_SCREEN;
    endcase
  end

  // Sets the game_clk according to the difficulty
  always_comb begin
      case(difficulty)
        1 : game_clk = game_clk1;
        2 : game_clk = game_clk2;
        3 : game_clk = game_clk3;
        4 : game_clk = game_clk4;
        5 : game_clk = game_clk5;
        6 : game_clk = game_clk6;
        default : game_clk = game_clk2;
      endcase
  end

endmodule