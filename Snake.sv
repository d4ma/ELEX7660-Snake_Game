module Snake (
    input logic CLOCK_50,  // 50 MHz clock

    output logic [7:0] leds,  // 7-seg LED enables
    output logic [3:0] ct,
    input logic s1,
	  input logic s2,
    input logic ir_signal

);  // digit cathodes

  logic [ 1:0] digit;  // select digit to display
  logic [ 3:0] disp_digit;  // current digit of count to display
  logic [15:0] clk_div_count;  // count used to divide clock

  logic [31:0] word;  // count used to track encoder movement and to display

  logic nec_clk;

  // instantiate modules to implement design
  decode2 decode2_0 (
      .digit,
      .ct
  );
  decode7 decode7_0 (
      .num(disp_digit),
      .leds
  );

  ir_freqgen #(50_000_000) ir_freqgen_0 (.nec_clk, .reset_n(s2), .clk(CLOCK_50));
  irReceiver irReceiver_0 (.ir_signal, .nec_clk, .word, .reset_n(s2));

  // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
  always_ff @(posedge CLOCK_50) clk_div_count <= clk_div_count + 1'b1;

  // assign the top two bits of count to select digit to display
  assign digit = clk_div_count[15:14];

  // Select digit to display (disp_digit)
  // Left most digit 0 display channel number and right three digits (3,2,1) display the ADC conversion result
  always_comb begin
    bit [3:0] nibble[4];
    nibble[0]  <= word[15:12];
    nibble[1]  <= word[11:8];
    nibble[2]  <= word[7:4];
    nibble[3]  <= word[3:0];

    disp_digit <= nibble[digit];
  end

endmodule




