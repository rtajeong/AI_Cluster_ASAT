`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Testbench for the Simple 2x2 Matrix Multiplier

module MatrixMultiplier_tb;

    // Parameters and Testbench Signals
    logic [15:0] A, B;       // Input matrices A and B
    logic start;             // Start signal
    logic clk, reset;        // Clock and reset signals
    logic [31:0] C;          // Output matrix C (expanded to 32 bits for larger values)
    logic done;              // Done signal

    // Debugging Signals (Matched with DUT)
    logic [2:0] debug_state;
    logic [1:0] debug_row, debug_col;
    logic [31:0] debug_accumulator, debug_temp_product; // Expanded to 32 bits for larger values

    // Instantiate the DUT (Device Under Test)
    MatrixMultiplier dut (
        .A(A),
        .B(B),
        .start(start),
        .clk(clk),
        .reset(reset),
        .C(C),
        .done(done)
    );

    // Clock Generation
    always #5 clk = ~clk; // 10ns clock period

    // Testbench Variables
    logic [31:0] expected_C; // Expanded to 32 bits

    // Test Procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        start = 0;
        A = 0;
        B = 0;

        // Apply Reset
        #10;
        reset = 0;

        // Test Case 1: A = [1 2; 3 4], B = [5 6; 7 8]
        A = 16'b0001_0010_0011_0100; // A = [[1, 2], [3, 4]]
        B = 16'b0101_0110_0111_1000; // B = [[5, 6], [7, 8]]
        expected_C = 32'b0000_0000_0001_0011_0000_0000_0010_1100; // C = [[19, 22], [43, 50]]

        // Start computation
        start = 1;
        #10;
        start = 0;

        // Wait for done signal
        wait(done);

        // Debugging information
        $display("State: %b, Row: %d, Col: %d", debug_state, debug_row, debug_col);
        $display("Accumulator: %h, Temp Product: %h", debug_accumulator, debug_temp_product);

        // Check results
        if (C == expected_C) begin
            $display("Test Case 1 Passed.");
        end else begin
            $display("Test Case 1 Failed. Expected: %h, Got: %h", expected_C, C);
        end

        // Add more test cases as needed
        
        // Test Case 2: A = [2 0; 1 3], B = [1 4; 2 0]
        A = 16'b0010_0000_0001_0011; // A = [[2, 0], [1, 3]]
        B = 16'b0001_0100_0010_0000; // B = [[1, 4], [2, 0]]
        expected_C = 32'b0000_0000_0000_1000_0000_0000_1010_0100; // C = [[2, 8], [10, 4]]

        start = 1;
        #10;
        start = 0;

        wait(done);

        // Debugging information
        $display("State: %b, Row: %d, Col: %d", debug_state, debug_row, debug_col);
        $display("Accumulator: %h, Temp Product: %h", debug_accumulator, debug_temp_product);

        // Check results
        if (C == expected_C) begin
            $display("Test Case 2 Passed.");
        end else begin
            $display("Test Case 2 Failed. Expected: %h, Got: %h", expected_C, C);
        end

        // Finish simulation
        $finish;
    end

endmodule




