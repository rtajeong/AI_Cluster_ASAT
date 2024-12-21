`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
// IEEE 754 16-bit Floating Point Representation Adder (Finite Numbers Only)
module FP16_Adder (
    input [15:0] F1, // First floating-point operand
    input [15:0] F2, // Second floating-point operand
    output reg [15:0] F3 // Result of addition
);

    // Constants for sign, exponent, and fraction bit widths
    parameter SIGN_BIT = 1;
    parameter EXP_BITS = 5;
    parameter FRAC_BITS = 10;
    parameter BIAS = 15;

    // Fields extraction
    wire sign1 = F1[15];
    wire sign2 = F2[15];
    wire [EXP_BITS-1:0] exp1 = F1[14:10];
    wire [EXP_BITS-1:0] exp2 = F2[14:10];
    wire [FRAC_BITS:0] frac1 = (exp1 == 0) ? {1'b0, F1[9:0]} : {1'b1, F1[9:0]}; // Add implicit leading 1 for normal numbers
    wire [FRAC_BITS:0] frac2 = (exp2 == 0) ? {1'b0, F2[9:0]} : {1'b1, F2[9:0]}; // Add implicit leading 1 for normal numbers

    // Intermediate signals
    reg [EXP_BITS-1:0] exp_diff;
    reg [FRAC_BITS+1:0] aligned_frac1, aligned_frac2;
    reg [FRAC_BITS+2:0] sum_frac;
    reg [EXP_BITS:0] result_exp;
    reg result_sign;

    always @(*) begin
        // Align exponents by shifting fractions
        if (exp1 > exp2) begin
            exp_diff = exp1 - exp2;
            aligned_frac1 = {frac1, 1'b0};
            aligned_frac2 = {frac2, 1'b0} >> exp_diff;
            result_exp = exp1;
        end else begin
            exp_diff = exp2 - exp1;
            aligned_frac1 = {frac1, 1'b0} >> exp_diff;
            aligned_frac2 = {frac2, 1'b0};
            result_exp = exp2;
        end

        // Add or subtract fractions based on signs
        if (sign1 == sign2) begin
            sum_frac = aligned_frac1 + aligned_frac2;
            result_sign = sign1;
        end else begin
            if (aligned_frac1 >= aligned_frac2) begin
                sum_frac = aligned_frac1 - aligned_frac2;
                result_sign = sign1;
            end else begin
                sum_frac = aligned_frac2 - aligned_frac1;
                result_sign = sign2;
            end
        end

        // Normalize result
        if (sum_frac[FRAC_BITS+2]) begin
            result_exp = result_exp + 1;
            sum_frac = sum_frac >> 1;
        end
        while (!sum_frac[FRAC_BITS+1] && result_exp > 0) begin
            sum_frac = sum_frac << 1;
            result_exp = result_exp - 1;
        end

        // Ensure proper underflow handling for small results
        if (result_exp == 0 && sum_frac[FRAC_BITS+1] == 0) begin
            F3 = 16'b0; // Zero result
        end else if (result_exp > 0) begin
            // Preserve the implicit bit in the final result
            F3 = {result_sign, result_exp[4:0], sum_frac[FRAC_BITS:1]};
        end else begin
            F3 = 16'b0; // Proper underflow to zero
        end
    end
endmodule
*/

// IEEE 754 16-bit Floating Point Representation Adder with Special Cases
module FP16_Adder (
    input [15:0] F1, // First floating-point operand
    input [15:0] F2, // Second floating-point operand
    output reg [15:0] F3 // Result of addition
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
    reg [EXP_BITS-1:0] exp_diff;
    reg [FRAC_BITS+1:0] aligned_frac1, aligned_frac2;
    reg [FRAC_BITS+2:0] sum_frac;
    reg [EXP_BITS:0] result_exp;
    reg result_sign;

    always @(*) begin
        // Handle special cases
        if (is_nan1 || is_nan2) begin
            F3 = 16'h7FFF; // NaN
        end else if (is_inf1 && is_inf2) begin
            if (sign1 == sign2) begin
                F3 = {sign1, 5'b11111, 10'b0}; // +Inf or -Inf
            end else begin
                F3 = 16'h7FFF; // NaN (inf - inf)
            end
        end else if (is_inf1) begin
            F3 = F1; // Return the infinity
        end else if (is_inf2) begin
            F3 = F2; // Return the infinity
        end else if (is_zero1) begin
            F3 = F2; // 0 + anything = anything
        end else if (is_zero2) begin
            F3 = F1; // anything + 0 = anything
        end else begin
            // Align exponents by shifting fractions
            if (exp1 > exp2) begin
                exp_diff = exp1 - exp2;
                aligned_frac1 = {frac1, 1'b0};
                aligned_frac2 = {frac2, 1'b0} >> exp_diff;
                result_exp = exp1;
            end else begin
                exp_diff = exp2 - exp1;
                aligned_frac1 = {frac1, 1'b0} >> exp_diff;
                aligned_frac2 = {frac2, 1'b0};
                result_exp = exp2;
            end

            // Add or subtract fractions based on signs
            if (sign1 == sign2) begin
                sum_frac = aligned_frac1 + aligned_frac2;
                result_sign = sign1;
            end else begin
                if (aligned_frac1 >= aligned_frac2) begin
                    sum_frac = aligned_frac1 - aligned_frac2;
                    result_sign = sign1;
                end else begin
                    sum_frac = aligned_frac2 - aligned_frac1;
                    result_sign = sign2;
                end
            end

            // Normalize result
            if (sum_frac[FRAC_BITS+2]) begin
                result_exp = result_exp + 1;
                sum_frac = sum_frac >> 1;
            end
            while (!sum_frac[FRAC_BITS+1] && result_exp > 0) begin
                sum_frac = sum_frac << 1;
                result_exp = result_exp - 1;
            end

            // Ensure proper underflow handling for small results
            if (result_exp == 0 && sum_frac[FRAC_BITS+1] == 0) begin
                F3 = 16'b0; // Zero result
            end else if (result_exp > 0) begin
                // Preserve the implicit bit in the final result
                F3 = {result_sign, result_exp[4:0], sum_frac[FRAC_BITS:1]};
            end else begin
                F3 = 16'b0; // Proper underflow to zero
            end
        end
    end
endmodule
