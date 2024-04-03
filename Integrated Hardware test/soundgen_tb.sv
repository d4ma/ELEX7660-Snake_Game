`timescale 1ns / 1ns

module soundgen_tb ();

  logic game_over, reset_n, food_eaten;  // clock and reset
  logic spkr, clk;

  soundgen dut_0 (.*);  // device under test

  initial begin
    food_eaten = 0;
    game_over = 0;
    reset_n = 1;
    clk = 0;

    // hold in reset for two clock cycles
    repeat (2) @(posedge clk);
    reset_n = 0;
    repeat (2) @(posedge clk);
    reset_n = 1;


    // wait for conversion start signal
    @(posedge clk);
    game_over = 1;
    @(posedge clk);
    game_over = 0;
    repeat (10_000_000) @(posedge clk);

    // hold in reset for two clock cycles
    repeat (2) @(posedge clk);
    reset_n = 0;
    repeat (2) @(posedge clk);
    reset_n = 1;


    // wait for conversion start signal
    repeat (50_000) @(posedge clk);
    food_eaten = 1;
    @(posedge clk);
    food_eaten = 0;
    repeat (10_000_000) @(posedge clk);

    $stop;

  end

  // generate clock
  always #10ns clk = ~clk;


endmodule



