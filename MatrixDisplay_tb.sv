// ELEX 7660 202010 Lab Project
// Testbench to test the MatrixDisplay module in daisy chaining mode
// Bryce Adam 2024/3/19


module MatrixDisplay_tb();

logic clk, reset;		 	 // clock
logic [15:0][15:0] grid;	 // input to the function
logic [15:0] configword = 0; // capture configuration word from adcinterface
logic [15:0] onword = 16'b00001100_00000001;
logic [15:0] brightword = 16'b00001010_00001111;
int j = 0;
logic [3:0] row_addr;
	
// max7219 signals
logic DIN, CS, LED_CLK;

MatrixDisplay dut_0 (.*);  // device under test


initial begin
	clk = 0;
	grid = '0;
	reset = 0;
	
	// loop until the startup sequence is complete

	for (int k = 0; k < 4; k++) begin
		// wait for LED clock pulse
		@(posedge LED_CLK);
			configword[15] = DIN;

			for (int i = 14; i>=0; i--)	begin
				@(posedge LED_CLK);
				// capture config word on positive edge
				configword[i] = DIN;
				@(negedge LED_CLK);
			end
		
		// verify that correct configuration word is sent for the selected channel
		$display ("Config work Check - %s: expected %4h, received %4h",  configword == onword ? "PASS" : "****FAIL****", onword, configword);

		configword = 0;
	end

	for (int k = 0; k < 4; k++) begin
		// wait LED clock pulse
		@(posedge LED_CLK);
			configword[15] = DIN;

			for (int i = 14; i>=0; i--)	begin
				@(posedge LED_CLK);
				// capture config word on positive edge
				configword[i] = DIN;
				@(negedge LED_CLK);
			end
			
		// verify that correct configuration word is sent for the selected channel
		$display ("Config work Check - %s: expected %4h, received %4h",  configword == brightword ? "PASS" : "****FAIL****", brightword, configword);

		configword = 0;
	end

	// Now loop through two sequences of commands to the led matrixes
	grid[0] = 16'b0000_0101_0101_1111
	grid[1] = 16'b0110_0110_1011_0001;
	grid[2] = 16'b0110_0110_1011_0000;
	grid[5] = 16'b01000010;
	grid[6] = 16'b00111100;

	for (int k = 0; k < 4; k++) begin
		for (j = 0; j<=7; j++) begin
			@(posedge LED_CLK);
				configword[15] <= DIN;

				for (int i = 14; i>=0; i--)	begin
					@(posedge LED_CLK);
					// capture config word on positive edge
					configword[i] = DIN;
					@(negedge LED_CLK);
				end

				$display ("Config work Check - %s: expected %4h, received %4h",  configword == {row_addr, grid[j][7:0]} ? "PASS" : "****FAIL****", {row_addr, grid[j][7:0]}, configword);
				configword = 0;
		end
	end

	// Repeat to make sure all the commands are sent out again
	for (int k = 0; k < 4; k++) begin 
		for (j = 0; j<=7; j++) begin
			@(posedge LED_CLK);
				configword[15] <= DIN;

				for (int i = 14; i>=0; i--)	begin
					@(posedge LED_CLK);
					// capture config word on positive edge
					configword[i] = DIN;
					@(negedge LED_CLK);
				end

				$display ("Config work Check - %s: expected %4h, received %4h",  configword == {row_addr, grid[j][7:0]} ? "PASS" : "****FAIL****", {row_addr, grid[j][7:0]}, configword);
				configword = 0;
		end
	end

	repeat(2) @(posedge clk)
	// Reset test starts here
	clk = 0;
	grid = '0;
	reset = 1;
	// loop until the startup sequence is complete
	repeat(2) @(posedge clk)
	reset = 0;

	// Check that everything still works after reset

	// wait for conversion start signal
	@(posedge LED_CLK);
		configword[15] = DIN;

		for (int i = 14; i>=0; i--)	begin
			@(posedge LED_CLK);
			// capture config word on positive edge
			configword[i] = DIN;
			@(negedge LED_CLK);
		end
	
	// verify that correct configuration word is sent for the selected channel
	$display ("Config work Check - %s: expected %4h, received %4h",  configword == onword ? "PASS" : "****FAIL****", onword, configword);

	configword = 0;

	// wait for conversion start signal
	@(posedge LED_CLK);
		configword[15] = DIN;

		for (int i = 14; i>=0; i--)	begin
			@(posedge LED_CLK);
			// capture config word on positive edge
			configword[i] = DIN;
			@(negedge LED_CLK);
		end
		
	// verify that correct configuration word is sent for the selected channel
	$display ("Config work Check - %s: expected %4h, received %4h",  configword == brightword ? "PASS" : "****FAIL****", brightword, configword);

	configword = 0;

	// Now loop through two sequences of commands to the led matrixes
	grid[1] = 8'b01100110;
	grid[2] = 8'b01100110;
	grid[5] = 8'b01000010;
	grid[6] = 8'b00111100;

	for (j = 0; j<=7; j++) begin
		@(posedge LED_CLK);
			configword[15] <= DIN;

			for (int i = 14; i>=0; i--)	begin
				@(posedge LED_CLK);
				// capture config word on positive edge
				configword[i] = DIN;
				@(negedge LED_CLK);
			end

			$display ("Config work Check - %s: expected %4h, received %4h",  configword == {row_addr, grid[j][7:0]} ? "PASS" : "****FAIL****", {row_addr, grid[j][7:0]}, configword);
			configword = 0;
	end

	// Repeat to make sure all the commands are sent out again
	for (j = 0; j<=7; j++) begin
		@(posedge LED_CLK);
			configword[15] <= DIN;

			for (int i = 14; i>=0; i--)	begin
				@(posedge LED_CLK);
				// capture config word on positive edge
				configword[i] = DIN;
				@(negedge LED_CLK);
			end

			$display ("Config work Check - %s: expected %4h, received %4h",  configword == {row_addr, grid[j][7:0]} ? "PASS" : "****FAIL****", {row_addr, grid[j][7:0]}, configword);
			configword = 0;
	end

	// Check that reset works in middle of transmission
	repeat(8) @ (posedge clk)
	reset = 1;
	repeat(3) @ (posedge clk)
	reset = 0;
	// Check that everything still works after reset

	// loop until the startup sequence is complete

	for (int k = 0; k < 4; k++) begin
		// wait for LED clock pulse
		@(posedge LED_CLK);
			configword[15] = DIN;

			for (int i = 14; i>=0; i--)	begin
				@(posedge LED_CLK);
				// capture config word on positive edge
				configword[i] = DIN;
				@(negedge LED_CLK);
			end
		
		// verify that correct configuration word is sent for the selected channel
		$display ("Config work Check - %s: expected %4h, received %4h",  configword == onword ? "PASS" : "****FAIL****", onword, configword);

		configword = 0;
	end

	for (int k = 0; k < 4; k++) begin
		// wait LED clock pulse
		@(posedge LED_CLK);
			configword[15] = DIN;

			for (int i = 14; i>=0; i--)	begin
				@(posedge LED_CLK);
				// capture config word on positive edge
				configword[i] = DIN;
				@(negedge LED_CLK);
			end
			
		// verify that correct configuration word is sent for the selected channel
		$display ("Config work Check - %s: expected %4h, received %4h",  configword == brightword ? "PASS" : "****FAIL****", brightword, configword);

		configword = 0;
	end

	$stop;
end

// generate clock
always
	#1ms clk = ~clk;
	
// Sets addresses to send commands to
always_comb begin
    if (j < 8)
        row_addr = 8 - j;
    else
        row_addr = 16 - j;
end

endmodule

