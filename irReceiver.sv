
module irReceiver (
    input logic ir_signal,
    input logic reset_n,
    output logic [31:0] word,
    input logic nec_clk
);

  // Define states
  typedef enum logic [3:0] {
    IDLE,
    START_LOW,
    START_HIGH,
    READ_BITS,
    END_STATE
  } state_t;
  state_t state = IDLE, next_state;

  logic prev_ir_signal;
  logic [31:0] count;
  logic [31:0] counter;

  logic [31:0] buffer;
  logic [5:0] bit_count;

  parameter [31:0] UP = 32'h20DF6A95;
  parameter [31:0] DOWN = 32'h20DFEA15;
  parameter [31:0] LEFT = 32'h20DF1AE5;
  parameter [31:0] RIGHT = 32'h20DF9A65;

  // State register and next state logic
  always_ff @(posedge nec_clk) begin
    if (~reset_n) begin
      state   <= IDLE;
      counter <= 0;
      buffer  <= 0;
      word <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (!ir_signal & prev_ir_signal) begin
            state   <= next_state;
            counter <= 0;
          end
        end
        START_LOW: begin
          if(counter < 165) begin
            if(counter > 155 & ~prev_ir_signal & ir_signal) begin
              state <= next_state;
              counter <= 0;
            end
            else begin
              counter <= counter + 1;
            end
          end
          else begin
            state <= IDLE;
          end
        end
        START_HIGH: begin
          if(counter < 85) begin
            if(counter > 75 & prev_ir_signal & ~ir_signal) begin
              state <= next_state;
              counter <= 0;
              count <= 0;
              bit_count <= 0;
            end
            else begin
              counter <= counter + 1;
            end
          end 
          else begin
            state <= IDLE;
          end
        end
        READ_BITS: begin
          if(counter < 1280 & count < 35) begin
            counter <= counter + 1;

            if(ir_signal)
              count <= count + 1;
            else if(prev_ir_signal) begin
              buffer <= {buffer[30:0], count >= 20 ? 1'b1 : 1'b0};
              bit_count <= bit_count + 1;
              count <= 0;
            end

            if(bit_count > 31) begin
              word <= buffer;
              state <= next_state;
            end
          end
          else begin
            state <= IDLE;
            counter <= 0;
            bit_count <= 0;
            count <= 0;
          end
        end
        END_STATE: begin
          if(ir_signal) state <= next_state;
        end
      endcase
    end
    prev_ir_signal <= ir_signal;

  end

  always_comb begin
    case (state)
      IDLE: next_state = START_LOW;
      START_LOW: next_state = START_HIGH;
      START_HIGH: next_state = READ_BITS;
      READ_BITS: next_state = END_STATE;
      END_STATE: next_state = IDLE;
    endcase
  end

endmodule
