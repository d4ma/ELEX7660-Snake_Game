// File: freqgen.sv
// Description: toggles the out_clk output at a desired frequency
// Author: Kento Sasaki 
// Date: 2024-04-09

module freqgen #(
    parameter FCLK
)  // clock frequency, Hz
(
    output logic out_clk,  // frequency output
    input logic reset_n,
    input logic [31:0] freq, // desired frequency
    input logic clk
);  // reset and clock

  logic [31:0] countup;

  always @(posedge clk) begin

    if (~reset_n) begin
      out_clk <= 0;
      countup <= 0;
    end else begin
      countup <= countup + (freq << 1);
      if (countup >= FCLK-(freq << 1)) begin
        countup <= 0;
        out_clk <= ~out_clk;
      end
    end

  end

endmodule

