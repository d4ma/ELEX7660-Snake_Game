// ELEX 7660 202010 Lab Project
// Testbench to test the snakegame module
// Bryce Adam 2024/3/27


module snakegame_tb();

logic game_clk, reset_n;		 	 // clock and reset
logic [15:0][15:0] grid;	 // output of the module
logic [31:0] direction;
logic [255:0][7:0] positions;

parameter [31:0] UP = 32'h20DF6A95;
parameter [31:0] DOWN = 32'h20DFEA15;
parameter [31:0] LEFT = 32'h20DF1AE5;
parameter [31:0] RIGHT = 32'h20DF9A65;

snakegame dut_0 (.*);  // device under test

initial begin
	game_clk = 0;
	reset_n = 1;
    direction = DOWN;
	
	repeat(1) @(posedge game_clk);
    reset_n = 0;
    repeat(2) @(posedge game_clk);
    reset_n = 1;
    repeat(2) @(posedge game_clk);
	direction = RIGHT;
	repeat(2) @(posedge game_clk);
		
	// verify that correct configuration word is sent for the selected channel
	$display ("Position array check - %s: expected %4h, received %4h",  positions[0] == 91 ? "PASS" : "****FAIL****", 91, positions[0]);
	$display ("Position array check - %s: expected %4h, received %4h",  positions[1] == 90 ? "PASS" : "****FAIL****", 90, positions[1]);
	$display ("Position array check - %s: expected %4h, received %4h",  positions[2] == 74 ? "PASS" : "****FAIL****", 74, positions[2]);
	$display ("Position array check - %s: expected %4h, received %4h",  positions[3] == 58 ? "PASS" : "****FAIL****", 58, positions[3]);
	$display ("Position array check - %s: expected %4h, received %4h",  positions[4] == 0 ? "PASS" : "****FAIL****", 0, positions[4]);

	$stop;
end

// generate clock
always
	#1ms game_clk = ~game_clk;


endmodule