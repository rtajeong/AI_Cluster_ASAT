`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Matrix Multiplier Design

module MatrixMultiplier (
    input logic [15:0] A, B,   // Input matrices A and B (4x4-bit representation)
    input logic start,        // Start signal
    input logic clk, reset,   // Clock and reset signals
    output logic [31:0] C,    // Output matrix C (expanded to 32 bits)
    output logic done,        // Done signal
    output logic [2:0] debug_state,  // Debug: FSM state
    output logic [1:0] debug_row,    // Debug: Current row
    output logic [1:0] debug_col,    // Debug: Current column
    output logic [31:0] debug_accumulator, // Debug: Accumulator value
    output logic [31:0] debug_temp_product // Debug: Temporary product
);

    // FSM State Encoding
    typedef enum logic [2:0] {
        IDLE    = 3'b000,
        LOAD    = 3'b001,
        COMPUTE = 3'b010,
        STORE   = 3'b011,
        DONE    = 3'b100
    } state_t;

    state_t current_state, next_state;

    // Registers and Intermediate Variables
    logic [7:0] a_reg [0:3], b_reg [0:3]; // Registers for matrices A and B
    logic [31:0] result_reg [0:3];        // Registers for result matrix C
    logic [1:0] row, col;                 // Row and column indices
    logic [31:0] accumulator, temp_product; // Expanded accumulator and temp product

    // Assign debugging signals
    assign debug_state = current_state;
    assign debug_row = row;
    assign debug_col = col;
    assign debug_accumulator = accumulator;
    assign debug_temp_product = temp_product;

    // State Transition Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            row <= 0;
            col <= 0;
            accumulator <= 0;
            done <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == COMPUTE) begin
                // Sequentially update row and column indices
                if (col == 1) begin
                    col <= 0;
                    row <= row + 1;
                end else begin
                    col <= col + 1;
                end
            end
        end
    end

    // Next State Logic
    always_comb begin
        case (current_state)
            IDLE:    next_state = start ? LOAD : IDLE;
            LOAD:    next_state = COMPUTE;
            COMPUTE: next_state = (row == 1 && col == 1) ? STORE : COMPUTE;
            STORE:   next_state = DONE;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Combinational Computation Logic
    always_comb begin
        temp_product = a_reg[row] * b_reg[col];
    end

    // Output and Store Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            C <= 0;
        end else if (current_state == STORE) begin
            result_reg[row * 2 + col] <= accumulator;
            C <= {result_reg[0], result_reg[1], result_reg[2], result_reg[3]};
            accumulator <= 0; // Reset accumulator
        end else if (current_state == COMPUTE) begin
            accumulator <= accumulator + temp_product;
        end
    end

endmodule


