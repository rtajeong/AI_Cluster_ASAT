`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


// IEEE 754 16-bit Floating Point Representation Multiplier with Special Cases
module FP16_Multiplier (
    input [15:0] F1, // First floating-point operand
    input [15:0] F2, // Second floating-point operand
    output reg [15:0] F3 // Result of multiplication
);

    // Constants for sign, exponent, and fraction bit widths
    parameter SIGN_BIT = 1;
    parameter EXP_BITS = 5;
    parameter FRAC_BITS = 10;
    parameter BIAS = 15;

    // Special number detection
    wire is_nan1 = (F1[14:10] == 5'b11111) && (F1[9:0] != 0);
    wire is_nan2 = (F2[14:10] == 5'b11111) && (F2[9:0] != 0);
    wire is_inf1 = (F1[14:10] == 5'b11111) && (F1[9:0] == 0);
    wire is_inf2 = (F2[14:10] == 5'b11111) && (F2[9:0] == 0);
    wire is_zero1 = (F1[14:0] == 0);
    wire is_zero2 = (F2[14:0] == 0);

    // Fields extraction
    wire sign1 = F1[15];
    wire sign2 = F2[15];
    wire [EXP_BITS-1:0] exp1 = F1[14:10];
    wire [EXP_BITS-1:0] exp2 = F2[14:10];
    wire [FRAC_BITS:0] frac1 = (exp1 == 0) ? {1'b0, F1[9:0]} : {1'b1, F1[9:0]}; // Add implicit leading 1 for normal numbers
    wire [FRAC_BITS:0] frac2 = (exp2 == 0) ? {1'b0, F2[9:0]} : {1'b1, F2[9:0]}; // Add implicit leading 1 for normal numbers

    // Intermediate signals
    reg [EXP_BITS:0] result_exp;
    reg [FRAC_BITS*2+1:0] product_frac;
    reg result_sign;

    always @(*) begin
        // Handle special cases
        if (is_nan1 || is_nan2) begin
            F3 = 16'h7FFF; // NaN
        end else if (is_inf1 || is_inf2) begin
            if (is_zero1 || is_zero2) begin
                F3 = 16'h7FFF; // NaN (inf * 0)
            end else begin
                F3 = {sign1 ^ sign2, 5'b11111, 10'b0}; // Inf with correct sign
            end
        end else if (is_zero1 || is_zero2) begin
            F3 = {sign1 ^ sign2, 15'b0}; // Zero with correct sign
        end else begin
            // Calculate result sign
            result_sign = sign1 ^ sign2;

            // Calculate result exponent
            result_exp = exp1 + exp2 - BIAS;

            // Multiply fractions
            product_frac = frac1 * frac2;

            // Normalize the result
            if (product_frac[FRAC_BITS*2+1]) begin
                product_frac = product_frac >> 1;
                result_exp = result_exp + 1;
            end

            // Check for overflow or underflow
            if (result_exp >= 31) begin
                F3 = {result_sign, 5'b11111, 10'b0}; // Overflow to infinity
            end else if (result_exp <= 0) begin
                F3 = 16'b0; // Underflow to zero
            end else begin
                // Construct the result
                F3 = {result_sign, result_exp[4:0], product_frac[FRAC_BITS+9:FRAC_BITS]};
            end
        end
    end
endmodule
