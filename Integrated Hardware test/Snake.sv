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
    input logic ir_signal,
	 output logic red, green, blue // RGB LED signals

);  // digit cathodes

  logic [1:0] digit;  // select digit to display
  logic [3:0] disp_digit;  // current digit of count to display
  logic [15:0] clk_div_count;  // count used to divide clock
  logic [4:0] led_clk_div_count; // count used to divide clock for led matrix

  logic [15:0][15:0] grid;
  logic [255:0][7:0] positions;

  logic [31:0] word;  // word from the ir reciever
  logic [7:0] length;
  logic [7:0] score;
  logic [7:0] foodPos;

  logic slow_clk; // Slower clock given to the led matrix
  logic game_clk; // Slower clock given to the game
  logic nec_clk; // Clock given to the ir_reciever

  // instantiate modules to implement design
  decode2 decode2_0 (
      .digit,
      .ct
  );
  decode7 decode7_0 (
      .num(disp_digit),
      .leds
  );
  

  freqgen #(50_000_000) ir_freqgen_0 (.out_clk(game_clk), .reset_n, .clk(CLOCK_50), .freq(4)); // Generate game clock
  freqgen #(50_000_000) ir_freqgen_1 (.out_clk(nec_clk), .reset_n, .clk(CLOCK_50), .freq(17_778));  // Generate irReceiver clock
  irReceiver irReceiver_0 (.ir_signal, .nec_clk, .word, .reset_n);
  snakegame snakegame_0 (.direction(word), .game_clk, .reset_n, .positions, .length, .foodPos);
  MatrixDisplay MatrixDisplay_0 (.clk(slow_clk), .reset_n, .grid, .DIN(led_din), .CS(led_cs), .LED_CLK(led_clk));
  pos2grid pos2grid_0 (.pos(positions), .length, .foodPos, .grid);

  // Clock dividing logic for the matrix display
  always_ff @(posedge CLOCK_50)
    led_clk_div_count <= led_clk_div_count + 1'b1;

  // assign the top bit of clk_div_count as the led clock
  assign slow_clk = led_clk_div_count[4];

  // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
  always_ff @(posedge CLOCK_50) clk_div_count <= clk_div_count + 1'b1;

  // assign the top two bits of count to select digit to display
  assign digit = clk_div_count[15:14];


  // Select digit to display (disp_digit)
  // Left most digit 0 display channel number and right three digits (3,2,1) display the ADC conversion result
  
  always_comb begin
    bit [3:0] nibble[4];
    nibble[0]  <= 4'b0;
    nibble[1]  <= 4'b0;
    nibble[2]  <= score[7:4];
    nibble[3]  <= score[3:0];

    disp_digit <= nibble[digit];
  end
  
  assign score = length * 5;

  assign {red, green, blue} = '0;
  
endmodule




