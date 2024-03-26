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
    input logic [7:0] length, foodpos,
    output logic [15:0][15:0] grid
);

    int i = 0;

    always_comb begin
        grid = '{default:0};

        // Draw the snake onto the grid
        for (i=0; i<length; i++)
            grid[pos[i]/16][15 - pos[i]%16] = 1'b1;

        // Place the food on the grid
        grid[foodpos/16][15 - foodpos%16] = 1'b1;
    end

endmodule