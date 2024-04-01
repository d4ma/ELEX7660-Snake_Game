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
    input logic [7:0] length, foodPos,
    output logic [15:0][15:0] grid
);

    logic [7:0] i = 0;

    always_comb begin
        grid = '{default:0};

        // Draw the snake onto the grid
        for (i = 0; i < 8'd8; i++) begin
            if ((i < length) && (i !== foodPos))
                grid[pos[i] >> 4][15 - pos[i]%16] = 1'b1;
            else
                grid[pos[i] >> 4][15 - pos[i]%16] = 1'b0;
        end   

        grid[foodPos >> 4][15 - foodPos%16] = 1'b1;
    end

endmodule