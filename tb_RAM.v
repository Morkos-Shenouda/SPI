`timescale 1ns/1ps

module tb_RAM();

    // Testbench signals
    reg [9:0] din;
    reg clk;
    reg rst;
    reg rx_valid;
    wire [9:0] dout;
    wire tx_valid;

    // Instantiate the Unit Under Test (UUT)
    RAM #(
        .MEM_WIDTH(8),
        .MEM_DEPTH(256)
    ) uut (
        .din(din),
        .clk(clk),
        .rst(rst),
        .rx_valid(rx_valid),
        .dout(dout),
        .tx_valid(tx_valid)
    );

    // Clock Generation (100MHz -> 10ns period)
    always #5 clk = ~clk;

    // Test Sequence
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0;
        rx_valid = 0;
        din = 10'b0;

        // Apply Reset
        #15 rst = 1; 

        // ---------------------------------------------------
        // TEST CASE 1: Write Data to Memory
        // ---------------------------------------------------
        
        // Step 1: Send Write Address (0xAA)
        @(negedge clk);
        rx_valid = 1;
        din = {2'b00, 8'hAA}; // Command 00 + Address 0xAA
        
        // Step 2: Send Write Data (0x55)
        @(negedge clk);
        din = {2'b01, 8'h55}; // Command 01 + Data 0x55

        // Stop driving inputs
        @(negedge clk);
        rx_valid = 0;
        din = 10'b0;

        #20; // Wait a few cycles

        // ---------------------------------------------------
        // TEST CASE 2: Read Data from Memory
        // ---------------------------------------------------
        
        // Step 3: Send Read Address (0xAA)
        @(negedge clk);
        rx_valid = 1;
        din = {2'b10, 8'hAA}; // Command 10 + Address 0xAA

        // Step 4: Send Read Command
        @(negedge clk);
        din = {2'b11, 8'h00}; // Command 11 + Dummy Data

        // Stop driving inputs
        @(negedge clk);
        rx_valid = 0;
        din = 10'b0;

        // Wait to observe output (dout should be 0x55, tx_valid should be 1)
        #20;

        // End Simulation
        $display("Simulation Complete.");
        $stop;
    end

    // Monitor Outputs
    initial begin
        $monitor("Time=%0t | rst=%b | rx_valid=%b | din=%b | dout=%h | tx_valid=%b", 
                 $time, rst, rx_valid, din, dout, tx_valid);
    end

endmodule