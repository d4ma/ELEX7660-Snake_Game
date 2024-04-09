// pos2grid.sv
// Converts game logic version of position to grid position
// so the snake and food can be draw onto the grid.
// Author: Bryce Adam
// Created: Mar 19, 2024
// Last Modified: Apr 09, 2024

module pos2grid
(
    input logic [255:0][7:0] pos,
    input logic [7:0] length, foodPos,
    input logic [15:0] grid_row,
    output logic [15:0] grid_col
);

    logic [7:0] i = 0;

    always_comb begin
        grid_col = '{default:0};

        // Draw the snake onto the grid for the current row
        for (i = 0; i < 8'd255; i++) begin
            if (((pos[i] >> 4) == grid_row) && (i < length))
                grid_col[15 - pos[i]%16] = 1'b1;
        end

        // Add food position to the grid if it is in the specified row
        if ((foodPos >> 4) == grid_row)
            grid_col[15 - foodPos%16] = 1'b1;
    end

endmodule