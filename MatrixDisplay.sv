// MatrixDisplay.sv
// Output signals to the Matrix display
// Bryce Adam
// Mar 05, 2024

module MatrixDisplay
(
    input logic clk,
    input logic [15:0][15:0] grid,

    // Signals to output to the daisy chained matrices
    output logic DIN, CS, LED_CLK
);

endmodule