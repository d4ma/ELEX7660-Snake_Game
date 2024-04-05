// File: Lab1.sv
// Description: ELEX 7660 lab1 module
// decodes 4 bit input into 7segment display output
// Author: Kento Sasaki 
// Date: 2024-01-11
module decode7 ( input logic [3:0] num, output logic [7:0] leds) ;
	always_comb begin
		case (num)
			4'h0 : leds = 8'b00111111; 
			4'h1 : leds = 8'b00000110; 
			4'h2 : leds = 8'b01011011;
			4'h3 : leds = 8'b01001111;
			4'h4 : leds = 8'b01100110;
			4'h5 : leds = 8'b01101101;
			4'h6 : leds = 8'b01111101;
			4'h7 : leds = 8'b00000111;
			4'h8 : leds = 8'b01111111;
			4'h9 : leds = 8'b01100111;
			4'hA : leds = 8'b01110111;
			4'hB : leds = 8'b01111100;
			4'hC : leds = 8'b00111001;
			4'hD : leds = 8'b01011110;
			4'hE : leds = 8'b01111001;
			4'hF : leds = 8'b01110001; 
		endcase
	end
endmodule
