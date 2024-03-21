// MatrixDisplay.sv
// Output signals to the Matrix display
// Author: Bryce Adam
// Created: Mar 05, 2024
// Last Modified: Mar 19, 2024

module MatrixDisplay
(
    input logic clk, reset, // clock signal and asynchronous reset
    input logic [15:0][15:0] grid,

    // Signals to output to the daisy chained matrices
    output logic DIN, CS, LED_CLK
);
    // define constants
    parameter on_reg = 8'b00001100;
    parameter turn_on = 8'b00000001; // Turn on the LED display
    parameter bright_reg = 8'b00001010;
    parameter brightness = 8'b00001111; // Set to max brightness

    int databit = 0;
    logic [1:0] matrix_num = 0;
    logic [3:0] grid_row = 0;
    logic [3:0] grid_col = 0;
    logic [7:0] row_addr = 0;
    logic [1:0] reset_counter = 0; // reset counter that snychronizes all signals so reset always works

    enum int unsigned {start, load, bright, transmit}
        state, prev_state;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            databit <= 0;
            reset_counter <= 2'b11;
        end else if (reset_counter) begin
            reset_counter <= reset_counter - 1;
            databit <= 1;
        end else begin
            if (state == load)
                databit <= 0;
            else if (state == transmit) begin
                if (databit < 16) begin
                    databit <= databit + 1;
                end else begin
                    databit <= 1;
                end
            end else if (databit < 16)
                databit <= databit + 1;
            else begin
                databit <= 1;
            end
        end
    end

    always_ff @(negedge clk, posedge reset) begin
        if (reset) begin 
            CS <= 1;
            DIN <= 0;
            state <= start;
            prev_state <= start;
            grid_row <= 0;
            matrix_num <= 0;
        end else if (reset_counter) begin
            CS <= 0;
            DIN <= 0;
            state <= start;
            prev_state <= start;
            grid_row <= 0;
            matrix_num <= 0;
        end else begin
            if(state == start) begin // execute the start command sequence
                CS <= 0;
                if(databit < 8)
                    DIN <= on_reg[7-databit]; // Send a bit of the on register
                else if (databit < 16) begin
                    DIN <= turn_on[15-databit]; // Send a bit of the turn on command
                end else begin
                    if (matrix_num < 2'b11) begin
                        matrix_num = matrix_num + 1;
                        DIN <= 0;
                    end else begin
                        state <= load;
                        prev_state <= start;
                        matrix_num = matrix_num + 1;
                        DIN <= 0;
                    end
                end
            end else if (state == load) begin // set data low and pulse 
                DIN <= 0;
                if (CS == 0) begin
                    CS <= 1;
                end else begin
                    CS <= 0;
                    if (prev_state == start)
                        state <= bright;
                    else
                        state <= transmit;
                end
            end else if (state == bright) begin
                CS <= 0;
                if(databit < 8)
                    DIN <= bright_reg[7-databit]; // Send a bit of the on register
                else if (databit < 16) begin
                    DIN <= brightness[15-databit]; // Send a bit of the set brightness to maximum command
                end else begin
                    if (matrix_num < 2'b11) begin
                        matrix_num = matrix_num + 1;
                        DIN <= 0;
                    end else begin
                        state <= load;
                        prev_state <= bright;
                        matrix_num = matrix_num + 1;
                        DIN <= 0;
                    end
                end
            end else if (state == transmit) begin // Most time should be spent here
                CS <= 0;
                if(databit < 8)
                    DIN <= row_addr[7-databit]; // Send a bit to specify the row address
                else if (databit < 16) begin
                    DIN <= grid[grid_row][grid_col]; // Send a bit of the turn on command
                end else begin
                    if (matrix_num < 2'b11) begin
                        matrix_num = matrix_num + 1;
                        DIN <= 0;
                    end else begin
                        state <= load;
                        matrix_num = matrix_num + 1;
                        DIN <= 0;
                        if (grid_row < 7)
                            grid_row <= grid_row + 1;
                        else
                            grid_row <= 0;
                    end
                end
            end
        end
    end

    // For now set LED_CLK equal to the input clock
    // May need to be divided or given state dependance later
    assign LED_CLK = ((state != load) && (!reset) && (!reset_counter)) ? clk : 1'b0;
   
    always_comb begin
        // Sets addresses to send commands to
        if (grid_row < 8)
            row_addr = 8 - grid_row;
        else
            row_addr = 16 - grid_row;

        // Sets the column to to get led lighting info from
        case (matrix_num)
            2'b00 : grid_col = 23 - databit;
            2'b01 : grid_col = 15 - databit;
            2'b10 : grid_col = 23 - databit;
            2'b11 : grid_col = 15 - databit;
        endcase
    end

endmodule