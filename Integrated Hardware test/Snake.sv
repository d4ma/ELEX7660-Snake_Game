// File: Snake.sv
// Description: Snakegame top level module that connects submodules together
// Author: Bryce Adam & Kento Sasaki
// Date: 2024-03-29

module Snake (
    input logic CLOCK_50,  // 50 MHz clock
    input logic reset_n,

    output logic [7:0] leds,  // 7-seg LED enables
    output logic [3:0] ct,
    output logic led_din, led_cs, led_clk,
    input logic s1,
	 input logic s2,
    input logic s3,
    input logic s4,
    // input logic ir_signal
    output logic red, green, blue // RGB LED signals

);  // digit cathodes

  logic [1:0] digit;  // select digit to display
  logic [3:0] disp_digit;  // current digit of count to display
  logic [15:0] clk_div_count;  // count used to divide clock
  logic [4:0] led_clk_div_count; // count used to divide clock for led matrix
  logic [24:0] game_clk_div_count; // count used to divide clock for the game
  logic game_clk; // Slower clock given to the game
  logic [15:0][15:0] grid;
  logic [255:0][7:0] positions;
  logic slow_clk; // Slower clock given to the led matrix

  parameter [31:0] UP = 32'h20DF6A95;
	parameter [31:0] DOWN = 32'h20DFEA15;
	parameter [31:0] LEFT = 32'h20DF1AE5;
	parameter [31:0] RIGHT = 32'h20DF9A65;

  logic [31:0] word;  // word from the ir reciever

  // logic nec_clk;

  // instantiate modules to implement design
  /*
  decode2 decode2_0 (
      .digit,
      .ct
  );
  decode7 decode7_0 (
      .num(disp_digit),
      .leds
  );
  */

  //ir_freqgen #(50_000_000) ir_freqgen_0 (.nec_clk, .reset_n(s2), .clk(CLOCK_50));
  //irReceiver irReceiver_0 (.ir_signal, .nec_clk, .word, .reset_n(s2));
  snakegame snakegame_0 (.direction(word), .game_clk, .reset_n, .grid, .positions);
  MatrixDisplay MatrixDisplay_0 (.clk(slow_clk), .reset_n, .grid, .DIN(led_din), .CS(led_cs), .LED_CLK(led_clk));

  // Clock dividing logic for the matrix display
  always_ff @(posedge CLOCK_50) begin
    led_clk_div_count <= led_clk_div_count + 1'b1;
    game_clk_div_count <= game_clk_div_count + 1'b1;
  end

  always_comb begin
    if(!s1)
      word = UP;
    else if(!s2)
      word = DOWN;
    else if(!s3)
      word = RIGHT;
    else if(!s4)
      word = LEFT;
    else
      word = '0;
  end

  // assign the top bit of clk_div_count as the led clock
  assign slow_clk = led_clk_div_count[4];

  // assign the top bit of clk_div_count as the game clock
  assign game_clk = game_clk_div_count[24];

  // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
  always_ff @(posedge CLOCK_50) clk_div_count <= clk_div_count + 1'b1;

  // assign the top two bits of count to select digit to display
  assign digit = clk_div_count[15:14];

  // turn off the RGB LED on the BoosterPack (I have received a few complaints about it)	
	assign {red, green, blue} = '0;

  // Select digit to display (disp_digit)
  // Left most digit 0 display channel number and right three digits (3,2,1) display the ADC conversion result
  /*
  always_comb begin
    bit [3:0] nibble[4];
    nibble[0]  <= word[15:12];
    nibble[1]  <= word[11:8];
    nibble[2]  <= word[7:4];
    nibble[3]  <= word[3:0];

    disp_digit <= nibble[digit];
  end
  */

endmodule




