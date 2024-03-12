
module irReceiver (
    input logic ir_signal,
    output logic [1:0] direction,
    input logic nec_clk
);

	logic prev_ir_signal;
	logic receiving = 0;
	logic receive_bits = 0;
	logic [31:0] count = 0;
	logic [31:0] buffer = 0;
	logic [5:0] bit_count = 0;
	logic [31:0] decoded_word = 0;

	parameter [31:0] UP = 32'h20DF6A95;
	parameter [31:0] DOWN = 32'h20DFEA15;
	parameter [31:0] LEFT = 32'h20DF1AE5;
	parameter [31:0] RIGHT = 32'h20DF9A65;
	
	always_comb begin
		case(decoded_word)
			UP : direction <= 0;
			DOWN : direction <= 1;
			LEFT : direction <= 2;
			RIGHT : direction <= 3;
			default : direction <= 0;
		endcase
	end

  always_ff @(posedge nec_clk) begin
		if(~prev_ir_signal & ir_signal & ~receiving) begin
			receiving <= 1;
			count <= 0;
		end

		if(receiving) begin

			if(prev_ir_signal & ~ir_signal & ~receive_bits) receive_bits <= 1;

			if(receive_bits) begin
				if(ir_signal) count <= count + 1;

				if(bit_count > 31 & ~prev_ir_signal & ir_signal) begin
					receive_bits <= 0;
					receiving <= 0;
					bit_count <= 0;
					decoded_word <= buffer;
				end

				if(prev_ir_signal & ~ir_signal) begin
					if(bit_count <= 31) buffer <= {buffer[30:0],(count >= 20) ? 1'b1 : 1'b0};
					bit_count <= bit_count + 1;
					count <= 0;
				end

			end

		end

    prev_ir_signal <= ir_signal;
  end

endmodule
