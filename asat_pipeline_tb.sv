`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


// Testbench for PipelineAdder
module Testbench;
    logic clk;
    logic rst;
    logic signed [31:0] A, B, C;
    logic signed [31:0] S;
    logic signed [31:0] debug_sum_stage1;
    logic signed [31:0] debug_C_stage1;

    // Instantiate the PipelineAdder
    PipelineAdder uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .C(C),
        .S(S),
        .debug_sum_stage1(debug_sum_stage1),
        .debug_C_stage1(debug_C_stage1)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize inputs
        rst = 1;
        A = 0;
        B = 0;
        C = 0;

        // Apply reset
        #10 rst = 0;

        // Apply test inputs
        repeat (10) begin
            #10 A = $urandom_range(-100, 100); 
                B = $urandom_range(-100, 100); 
                C = $urandom_range(-100, 100);
        end

        // Wait for output to stabilize
        #50;

        // Finish simulation
        $stop;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0t | A: %0d, B: %0d, C: %0d | debug_sum_stage1: %0d | debug_C_stage1: %0d | S: %0d", $time, A, B, C, debug_sum_stage1, debug_C_stage1, S);
    end
endmodule