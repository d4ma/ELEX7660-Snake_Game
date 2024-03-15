
module snakegame (
    input logic [1:0] direction,
    output logic [15:0][15:0] grid,
    input logic game_clk, reset_n
);

    logic [3:0] snakePos_x, snakePos_y, foodPos_x, foodPos_y; 
    logic [7:0] length;

    always_ff @(posedge game_clk) begin
        if(~reset_n) begin
            snakePos_x <= 8;
            snakePos_y <= 8;
            foodPos_x <= 4;
            foodPos_x <= 4;
            length = 1;
        end
        else begin
            case(direction)
                0 : snakePos_y <= snakePos_y + 1;
                1 : snakePos_y <= snakePos_y - 1;
                2 : snakePos_x <= snakePos_x - 1;
                3 : snakePos_x <= snakePos_x + 1;
            endcase
        end
    end

endmodule

