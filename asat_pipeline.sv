`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


// Pipeline design for A + B + C using two pipeline stages
module PipelineAdder (
    input logic clk,
    input logic rst,
    input logic signed [31:0] A,
    input logic signed [31:0] B,
    input logic signed [31:0] C,
    output logic signed [31:0] S,
    output logic signed [31:0] debug_sum_stage1,
    output logic signed [31:0] debug_C_stage1
);
    // Pipeline registers
    logic signed [31:0] sum_stage1;
    logic signed [31:0] C_stage1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sum_stage1 <= 32'sd0;
            C_stage1 <= 32'sd0;
            S <= 32'sd0;
        end else begin
            // Stage 1: A + B, latch C
            sum_stage1 <= A + B;
            C_stage1 <= C;
            // Stage 2: sum_stage1 + C_stage1
            S <= sum_stage1 + C_stage1;
        end
    end

    // Debug output for intermediate pipeline registers
    assign debug_sum_stage1 = sum_stage1;
    assign debug_C_stage1 = C_stage1;
endmodule
