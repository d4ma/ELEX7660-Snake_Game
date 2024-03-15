// File: freqgen.sv
// Description: toggles the nec_clk output at a desired frequency
// Author: Kento Sasaki 
// Date: 2024-02-03

module ir_freqgen #(
    parameter FCLK
)  // clock frequency, Hz
(
    output logic nec_clk,  // speaker output
    input logic reset_n,
    clk
);  // reset and clock

  logic [31:0] countup;
  logic [31:0] freq = 17_778;

  always @(posedge clk) begin

    if (~reset_n) begin
      nec_clk <= 0;
      countup <= 0;
    end else begin
      countup <= countup + (freq << 1);
      if (countup >= FCLK-(freq << 1)) begin
        countup <= 0;
        nec_clk <= ~nec_clk;
      end
    end

  end

endmodule

