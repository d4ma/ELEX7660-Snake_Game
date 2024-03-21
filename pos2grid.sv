// pos2grid.sv
// Converts game logic version of position to grid position
// so the snake can be draw onto the grid.
// Will need to be updated to draw the food as well.
// Author: Bryce Adam
// Created: Mar 19, 2024
// Last Modified: Mar 20, 2024

module pos2grid
(
    input logic [255:0][7:0] pos,
    input logic [7:0] length,
    output logic [15:0][15:0] grid
);

    int i = 0;

    always_comb begin
        grid = '{default:0};

        for (i=0; i<length; i++)
            grid[pos[i]/16][pos[i]%16] = 1'b1;
    end

endmodule