`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

/*
// Testbench for the FP16_Adder (Finite Numbers Only)
module FP16_Adder_tb;
    reg [15:0] F1, F2;
    wire [15:0] F3;

    FP16_Adder uut (
        .F1(F1),
        .F2(F2),
        .F3(F3)
    );

    // Task to display results in floating-point decimal format
    task display_result;
        input [15:0] in1, in2, out;
        real val1, val2, val3;
        begin
            val1 = convert_to_real(in1);
            val2 = convert_to_real(in2);
            val3 = convert_to_real(out);
            $display("F1: %h (%f), F2: %h (%f), F3: %h (%f)", in1, val1, in2, val2, out, val3);
        end
    endtask

    // Task to convert 16-bit floating-point to real
    function real convert_to_real;
        input [15:0] fp;
        reg sign;
        reg [4:0] exponent;
        reg [10:0] fraction;
        real value;
        begin
            sign = fp[15];
            exponent = fp[14:10];
            fraction = fp[9:0];
            if (exponent == 0) begin
                value = 0.0;
            end else begin
                value = (1.0 + (fraction / 1024.0)) * (2.0 ** (exponent - 15));
                value = (sign) ? -value : value;
            end
            convert_to_real = value;
        end
    endfunction

    initial begin
        // Updated test cases
        F1 = 16'h3D00; // 1.625
        F2 = 16'h4680; // 4.75
        #10 display_result(F1, F2, F3);

        F1 = 16'h3D00; // 1.625
        F2 = 16'hC680; // -4.75
        #10 display_result(F1, F2, F3);

        F1 = 16'hBD00; // -1.625
        F2 = 16'h4680; // 4.75
        #10 display_result(F1, F2, F3);

        F1 = 16'hBD00; // -1.625
        F2 = 16'hC680; // -4.75
        #10 display_result(F1, F2, F3);

        // Additional test cases
        F1 = 16'h3C00; // 1.5
        F2 = 16'h4400; // 3.0
        #10 display_result(F1, F2, F3);

        F1 = 16'hBC00; // -1.5
        F2 = 16'h4400; // 3.0
        #10 display_result(F1, F2, F3);

        F1 = 16'h3E00; // 1.75
        F2 = 16'h4200; // 2.5
        #10 display_result(F1, F2, F3);

        F1 = 16'hBE00; // -1.75
        F2 = 16'h4200; // 2.5
        #10 display_result(F1, F2, F3);

        // Finish simulation
        $stop;
    end
endmodule
*/


// Testbench for the FP16_Adder with Special Cases
module FP16_Adder_tb;
    reg [15:0] F1, F2;
    wire [15:0] F3;

    FP16_Adder uut (
        .F1(F1),
        .F2(F2),
        .F3(F3)
    );

    // Task to display results in floating-point decimal format
    task display_result;
        input [15:0] in1, in2, out;
        real val1, val2, val3;
        begin
            val1 = convert_to_real(in1);
            val2 = convert_to_real(in2);
            val3 = convert_to_real(out);
            $display("F1: %h (%f), F2: %h (%f), F3: %h (%f)", in1, val1, in2, val2, out, val3);
        end
    endtask

    // Task to convert 16-bit floating-point to real
    function real convert_to_real;
        input [15:0] fp;
        reg sign;
        reg [4:0] exponent;
        reg [10:0] fraction;
        real value;
        begin
            sign = fp[15];
            exponent = fp[14:10];
            fraction = fp[9:0];
            if (exponent == 0) begin
                value = 0.0;
            end else if (exponent == 5'b11111) begin
                value = (fraction == 0) ? ((sign) ? -1.0/0.0 : 1.0/0.0) : 0.0/0.0; // Inf or NaN
            end else begin
                value = (1.0 + (fraction / 1024.0)) * (2.0 ** (exponent - 15));
                value = (sign) ? -value : value;
            end
            convert_to_real = value;
        end
    endfunction

    initial begin
        // Test special cases
        F1 = 16'h7C00; // +Inf
        F2 = 16'h7C00; // +Inf
        #10 display_result(F1, F2, F3);

        F1 = 16'h7C00; // +Inf
        F2 = 16'hFC00; // -Inf
        #10 display_result(F1, F2, F3);

        F1 = 16'h7FFF; // NaN
        F2 = 16'h7C00; // +Inf
        #10 display_result(F1, F2, F3);

        F1 = 16'h0000; // +0
        F2 = 16'h8000; // -0
        #10 display_result(F1, F2, F3);

        F1 = 16'h3D00; // 1.625
        F2 = 16'h0000; // +0
        #10 display_result(F1, F2, F3);

        F1 = 16'h8000; // -0
        F2 = 16'h4680; // 4.75
        #10 display_result(F1, F2, F3);

        // Additional finite-number combinations
        F1 = 16'h3C00; // 1.5
        F2 = 16'h4200; // 2.5
        #10 display_result(F1, F2, F3);

        F1 = 16'h4000; // 2.0
        F2 = 16'h3C00; // 1.5
        #10 display_result(F1, F2, F3);

        F1 = 16'h4500; // 5.0
        F2 = 16'hC400; // -4.0
        #10 display_result(F1, F2, F3);

        F1 = 16'h4600; // 7.0
        F2 = 16'hC500; // -5.0
        #10 display_result(F1, F2, F3);

        F1 = 16'h3E00; // 1.75
        F2 = 16'h3D00; // 1.625
        #10 display_result(F1, F2, F3);

        F1 = 16'h3E00; // 1.75
        F2 = 16'hBE00; // -1.75
        #10 display_result(F1, F2, F3);

        // Finish simulation
        $stop;
    end
endmodule



