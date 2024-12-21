`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


// FSM Design: Counter FSM
module FSM_Counter (
    input logic clk,
    input logic rst,
    input logic start,
    input logic [31:0] N,
    output logic done,
    output logic [31:0] count,
    output logic [1:0] state_out
);
    // Define state encoding
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        PROCESS = 2'b01,
        DONE = 2'b10
    } state_t;

    state_t current_state, next_state;

    // Registers for count and done signal
    logic [31:0] count_reg;

    // Sequential logic: State transition
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            count_reg <= 0;
        end else begin
            current_state <= next_state;

            if (current_state == PROCESS) begin
                if (count_reg < N) begin
                    count_reg <= count_reg + 1;
                end else begin
                    count_reg <= 0; // Reset counter after reaching target
                end
            end else begin
                count_reg <= 0;
            end
        end
    end

    // Combinational logic: Next state logic
    always_comb begin
        case (current_state)
            IDLE: begin
                if (start) begin
                    next_state = PROCESS;
                end else begin
                    next_state = IDLE;
                end
            end
            PROCESS: begin
                if (count_reg == N) begin
                    next_state = DONE;
                end else begin
                    next_state = PROCESS;
                end
            end
            DONE: begin
                if (!start) begin
                    next_state = IDLE;
                end else begin
                    next_state = DONE;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    // Combinational logic: Output logic
    always_comb begin
        done = (current_state == DONE);
        count = count_reg;
        state_out = current_state; // Expose current state for debugging
    end

endmodule