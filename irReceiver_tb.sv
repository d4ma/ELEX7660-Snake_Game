`timescale 1us / 1us

module irReceiver_tb ();

  logic nec_clk, reset_n, ir_signal;  // clock and reset
  real burst;
  logic [31:0] iroutput;
  logic [31:0] word;
  localparam [31:0] CODES [4] = '{32'h20DF6A95, 32'h20DFEA15, 32'h20DF1AE5, 32'h20DF9A65};

  irReceiver dut_0 (.*);  // device under test

  initial begin
    ir_signal = 1;
    nec_clk = 0;
    reset_n = 0;
    burst = 562500ns;

    // hold in reset for two clock cycles
    repeat (10) @(posedge nec_clk);

    reset_n = 1;

    // loop for each possible channel

    // wait for conversion start signal
    @(posedge nec_clk);


    for(int i = 0; i < 4; i++) begin
        iroutput  = CODES[i];
        #5ms;
        ir_signal = 0;
        #9ms;
        ir_signal = 1;
        #4500us;
        for (int i = 31; i >= 0; i--) begin
        ir_signal = 0;
        #burst;
        ir_signal = 1;
        #(burst + 2 * burst * iroutput[i]);
        end
        ir_signal = 0;
        #burst;
        ir_signal = 1;
        #5ms;
    end
    

    $stop;

  end

  // generate clock
  always #28126ns nec_clk = ~nec_clk;


endmodule


