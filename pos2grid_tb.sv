// pos2grid.sv
// Testbench to test pos2grid module
// Author: Bryce Adam
// Created: Mar 20, 2024
// Last Modified: Mar 20, 2024

module pos2grid_tb();

    logic clk = 0;
    logic [15:0][15:0] grid;
    logic [7:0] length = 3;
    logic [255:0][7:0] pos = '{default:0};

    pos2grid dut_0 (.pos, .length, .grid); // device under test

    initial begin
        clk = 0;
        pos[0] = 10;
        pos[1] = 26;
        pos[2] = 42;
        pos[3] = 58;
        pos[4] = 59;

        repeat(2) @(posedge clk);

        pos = '{default:0};
        pos[0] = 0;
        pos[1] = 255;
        pos[2] = 78;
        pos[3] = 23;
        repeat(2) @(posedge clk);

        length = 4;
        repeat(2) @(posedge clk);

        $stop;
    end

    // generate clock
    always
	    #1ms clk = ~clk;

endmodule