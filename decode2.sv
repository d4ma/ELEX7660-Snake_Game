// File: decode2.sv
// Description: ELEX 7660 lab1 module
// decodes 2 bit input into 4bit active low position for the 4digit 7segment display 
// Author: Kento Sasaki 
// Date: 2024-01-11

module decode2 ( input logic [1:0] digit, output logic [3:0] ct) ;
  always_comb
  begin
    case (digit)
      3 :
        ct = 4'b1110 ;
      2 :
        ct = 4'b1101 ;
      1 :
        ct = 4'b1011 ;
      0 :
        ct = 4'b0111 ;
    endcase
  end
endmodule
