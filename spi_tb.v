`timescale 1ns/1ps
module SPI_tb ();
    reg clk;
    reg rst;
    reg SS_n;
    reg MOSI;
    wire MISO; 
    
    reg [7:0] r1; // Register to hold the read data for verification
    integer i; // Loop variable for reading MISO bits
    

    top spi (
        .clk(clk),
        .rst_n(rst),
        .SS_n(SS_n),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    initial begin
        clk = 0; // FIX 2: Initialize clk here to prevent setup race conditions
        forever begin
            #5 clk=~clk;
        end
    end

    initial begin
       
        rst = 0;
        SS_n = 1;
        MOSI = 0;
        r1 = 0;

        #20 rst = 1; // Release reset after 20ns

        // Simulate SPI writing
        @(negedge clk); SS_n = 0; // Assert SS_n to start communication
           //address to be sent is h'02
        MOSI = 0; @(negedge clk);
        MOSI = 0; @(negedge clk);
        MOSI = 0; @(negedge clk);
        MOSI = 0; @(negedge clk);
        MOSI = 0; @(negedge clk);
        MOSI = 0; @(negedge clk);
        MOSI = 0; @(negedge clk);
        MOSI = 0; @(negedge clk);
        MOSI = 1; @(negedge clk);
        MOSI = 1; @(negedge clk);   
        @(negedge clk);     

        // #10; // Wait for a few cycles to ensure the slave processes the command

        @(negedge clk); SS_n = 1; // Deassert SS_n to end communication


        //Now we send the data to be written to the register
        @(negedge clk); SS_n = 0; // Assert SS_n to start communication
        //data to be written is h'A9
        @(negedge clk); MOSI =0 ; // Send tenth bit (write command)
        @(negedge clk); MOSI =1 ; // Send ninth bit
        @(negedge clk); MOSI =1 ; // Send 8th bit
        @(negedge clk); MOSI =0 ; // Send 7th bit
        @(negedge clk); MOSI =1; // Send 6th bit
        @(negedge clk); MOSI =0 ; // Send 5th bit
        @(negedge clk); MOSI =1; // Send 4th bit
        @(negedge clk); MOSI =0 ; // Send 3rd bit
        @(negedge clk); MOSI =0; // Send 2nd bit
        @(negedge clk); MOSI = 1; // Send 1st bit
        #10; // Wait for a few cycles to ensure the slave processes the command
        @(negedge clk); SS_n = 1; // Deassert SS_n to end communication

       
        #10;

        //Simulate SPI reading

        @(negedge clk); SS_n = 0; // Assert SS_n to start communication
        //address to be read is h'02
        @(negedge clk); MOSI = 1; // Send first bit
        @(negedge clk); MOSI = 0; // Send second bit
        @(negedge clk); MOSI = 0; // Send third bit
        @(negedge clk); MOSI = 0; // Send fourth bit
        @(negedge clk); MOSI = 0; // Send fifth bit
        @(negedge clk); MOSI = 0; // Send sixth bit
        @(negedge clk); MOSI = 0; // Send seventh bit
        @(negedge clk); MOSI = 0; // Send eighth bit
        @(negedge clk); MOSI = 1; // Send ninth bit (read command)
        @(negedge clk); MOSI = 0; // Send tenth bit (read command)
        #10; // Wait for a few cycles to ensure the slave processes the command
        @(negedge clk); SS_n = 1; // Deassert SS_n to end communication
        
        #10;

        // now we check the value of MISO to see if the correct data is being read from the register
        @(negedge clk); SS_n = 0; // Assert SS_n to start communication
        //address to be read is h'02
        @(negedge clk); MOSI = 1; // Send first bit
        @(negedge clk); MOSI = 1; // Send second bit
        @(negedge clk); MOSI = 0; // Send third bit
        @(negedge clk); MOSI = 0; // Send fourth bit
        @(negedge clk); MOSI = 0; // Send fifth bit
        @(negedge clk); MOSI = 0; // Send sixth bit
        @(negedge clk); MOSI = 0; // Send seventh bit
        @(negedge clk); MOSI = 0; // Send eighth bit
        @(negedge clk); MOSI = 0; // Send ninth bit (read command)
        @(negedge clk); MOSI = 0; // Send tenth bit (read command)
        #15; // Wait for a few cycles to ensure the slave processes the command

        for (i = 7; i >= 0; i = i - 1) begin
            @(posedge clk); r1[i] = MISO; // FIX 6: Sample MISO on the positive edge of the clock to ensure proper timing
        end
        
        if(r1[7:0] === 8'hA9) begin
            $display("Test Passed: Data read correctly from the register.");
        end else begin
            $display("Test Failed: Data not read correctly from the register. Expected: 0xA9, Got: 0x%h", r1[7:0]);
        end
        @(negedge clk); SS_n = 1; // Deassert SS_n to end communication
        #10;

        $stop; // End the simulation
    end
endmodule 