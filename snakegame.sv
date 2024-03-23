function bit is_unique_position(logic [7:0] length, logic [7:0] pos, logic [255:0][7:0] positions);
  for (int i = 0; i < length; i++) begin
    if (positions[i] == pos) return 0; // Position is in the snake's body
  end
  return 1; // Unique position
endfunction

module snakegame (
    input logic [31:0] direction,
    output logic [15:0][15:0] grid,
    input logic game_clk, reset_n
);

    logic [7:0] foodPos; 
    logic [7:0] length;
    logic [255:0][7:0] positions;
    bit found;

    always_ff @(posedge game_clk) begin
        if(~reset_n) begin
            positions <= '0 | 8'128;
            foodPos <= 144;
            length = 1;
        end
        else begin            
            case(direction)
                32'h20DF6A95 : positions <= {positions[254:0], positions[0] - 16};
                32'h20DFEA15 : positions <= {positions[254:0], positions[0] + 16};
                32'h20DF1AE5 : positions <= {positions[254:0], positions[0] - 1};
                32'h20DF9A65 : positions <= {positions[254:0], positions[0] + 1};
            endcase

            if(foodPos == positions[0]) begin
                length <= length + 1;

                found <= 0;
                while (!found) begin
                    // Randomize foodPos
                    if (!std::randomize(foodPos) with { foodPos inside {[0:255]}; }) begin
                    $fatal("Randomization failed");
                    end
                    // Check if the randomized position is not in the snake's body
                    found <= is_unique_position(length, foodPos, positions);
                end
                // Now foodPos is guaranteed to be unique

                foodPos <= randomnum;
            end

        end
    end

endmodule

	// parameter [31:0] UP = 32'h20DF6A95;
	// parameter [31:0] DOWN = 32'h20DFEA15;
	// parameter [31:0] LEFT = 32'h20DF1AE5;
	// parameter [31:0] RIGHT = 32'h20DF9A65;