function logic is_unique_position(logic [7:0] length, logic [7:0] pos, logic [255:0][7:0] positions);
  for (int i = 0; i < length; i++) begin
    if (positions[i] == pos) return 0; // Position is in the snake's body
  end
  return 1; // Unique position
endfunction

module snakegame (
    input logic [31:0] direction,
    input logic game_clk, reset_n,
    output logic [15:0][15:0] grid,
    output logic [255:0][7:0] positions
);

    logic [7:0] foodPos; 
    logic [7:0] length;
    // logic [255:0][7:0] positions;
    logic found;
    logic rand_success;

    parameter [31:0] UP = 32'h20DF6A95;
	parameter [31:0] DOWN = 32'h20DFEA15;
	parameter [31:0] LEFT = 32'h20DF1AE5;
	parameter [31:0] RIGHT = 32'h20DF9A65;

    pos2grid pos2grid_0 (.pos(positions), .length, .foodPos, .grid);

    always_ff @(posedge game_clk) begin
        if(~reset_n) begin
            positions <= '{default:0};
            positions[0] <= 8'd58;
            foodPos <= 144;
            length = 1;
        end
        else begin
            // Shift all positions down the array
            for (int i = 255; i > 0; i--)
                positions[i] <= positions[i-1];

            case(direction)
                UP : positions[0] <= positions[0] - 16;
                DOWN : positions[0] <= positions[0] + 16;
                LEFT : positions[0] <=  positions[0] - 1;
                RIGHT : positions[0] <= positions[0] + 1;
            endcase

            if(foodPos == positions[0]) begin
                length <= length + 1;
                found <= 0;
                while (!found) begin
                    // Randomize foodPos
                    rand_success = std::randomize(foodPos);
                    // Check if the randomized position is not in the snake's body
                    found <= is_unique_position(length, foodPos, positions);
                end
                // Now foodPos is guaranteed to be unique
            end

        end
    end

endmodule