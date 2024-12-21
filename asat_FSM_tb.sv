`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



// Testbench for FSM_Counter
module Testbench_FSM_Counter;
    logic clk;
    logic rst;
    logic start;
    logic [31:0] N;
    logic done;
    logic [31:0] count;
    logic [1:0] state_out;

    // Instantiate FSM_Counter
    FSM_Counter uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .N(N),
        .done(done),
        .count(count),
        .state_out(state_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        rst = 1;
        start = 0;
        N = 0;

        // Apply reset
        #10 rst = 0;
        
        // Test case 1: Count to 5
        #10 N = 5; start = 1;
        #10 start = 0; // Deactivate start

        // Wait for done signal
        wait(done);
        #10;

        // Test case 2: Count to 10
        #10 N = 10; start = 1;
        #10 start = 0; // Deactivate start

        // Wait for done signal
        wait(done);
        #10;

        // Additional cycles for observation
        #50;

        // Finish simulation
        $stop;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0t | State: %0b | N: %0d | Count: %0d | Done: %0b", $time, state_out, N, count, done);
    end

endmodule

