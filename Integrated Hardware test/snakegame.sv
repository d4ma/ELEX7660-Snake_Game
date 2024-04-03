// File: snakegame.sv
// Description: Snake game logic module
// Author: Bryce Adam & Kento Sasaki
// Date: 2024-03-29

module snakegame (
    input logic [31:0] direction,
    input logic game_clk, reset_n,
    output logic [255:0][7:0] positions,
    output logic [7:0] length,
    output logic [7:0] foodPos
);

    parameter [31:0] UP = 32'h20DF6A95;
	parameter [31:0] DOWN = 32'h20DFEA15;
	parameter [31:0] LEFT = 32'h20DF1AE5;
	parameter [31:0] RIGHT = 32'h20DF9A65;

    logic [7:0] foodPos_next = 0;
    

    always_ff @(posedge game_clk, negedge reset_n) begin
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
                default : positions[0] <= positions[0];
            endcase
				
				foodPos_next <= foodPos_next + 7;

            if(foodPos == positions[0]) begin
                foodPos <= foodPos_next;
                length <= length + 1;
            end
        end
    end

endmodule