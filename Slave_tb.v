module Slave_tb ();

//notice that I don't know if the rx_data and rx_valid can be captured once the 10 clock
// cycles immediately end? or I have to wait another clock cycle. 
// So please check this if it gives you an error message.

reg clk;
reg rst_n;
reg MOSI;
reg SS_n;
reg [7:0] tx_data;
reg tx_valid;

wire MISO;
wire [9:0] rx_data;
wire rx_valid;

Slave dut(
    .clk(clk),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .SS_n(SS_n),
    .tx_data(tx_data),
    .tx_valid(tx_valid),
    .MISO(MISO),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
);

reg [9:0] MOSI_tmp;
integer i;


initial begin
    clk=0;
    forever #10 clk=~clk;
end

initial begin
    rst_n=0;
    MOSI=0;
    SS_n=1;
    tx_data=0;
    tx_valid=0;

    // -----------------------------------------------------------------------------
    // testing SS_n works
    // -----------------------------------------------------------------------------
    @(negedge clk);
    rst_n=1;
    SS_n=1;
    repeat(11) @(negedge clk);

    // -----------------------------------------------------------------------------
    // testing write address
    // testing rx_data is getting MOSI after 11 clock cycles
    // -----------------------------------------------------------------------------
    MOSI_tmp=10'h010; //first 2 bits must be 00 
    SS_n=0;
    MOSI=0;
    @(negedge clk);
    MOSI=0;
    @(negedge clk);
    for (i=9;i>=0;i=i-1) begin
        MOSI=MOSI_tmp[i];
        @(negedge clk);
    end

    @(negedge clk);

    if(rx_data!==MOSI_tmp || rx_valid!==1) begin
        $display("Write address doesn't work");
        $stop;
    end
    SS_n=1;
    @(negedge clk);


    // -----------------------------------------------------------------------------
    // testing write data
    // -----------------------------------------------------------------------------
    MOSI_tmp=10'h1AB; //first 2 bits must be 01
    SS_n=0;
    MOSI=0;
    @(negedge clk);
    MOSI=0;
    @(negedge clk);
    for(i=9;i>=0;i=i-1) begin
        MOSI=MOSI_tmp[i];
        @(negedge clk);
    end

    @(negedge clk);
    
    if(rx_data!==MOSI_tmp || rx_valid!==1) begin
        $display("Write data doesn't work");
        $stop;
    end
    SS_n=1;
    @(negedge clk);

    // -----------------------------------------------------------------------------
    // testing read address
    // -----------------------------------------------------------------------------
    MOSI_tmp=10'h2CD; //first 2 bits must be 10
    SS_n=0;
    MOSI=0;
    @(negedge clk);
    MOSI=1;
    @(negedge clk);
    for(i=9;i>=0;i=i-1) begin
        MOSI=MOSI_tmp[i];
        @(negedge clk);
    end

    @(negedge clk);

    if(rx_data!==MOSI_tmp || rx_valid!==1) begin
        $display("read address doesn't work");
        $stop;
    end
    SS_n=1;
    @(negedge clk);

    // -----------------------------------------------------------------------------
    // testing read data
    // -----------------------------------------------------------------------------
    MOSI_tmp=10'h3EF; //first 2 bits bust be 11. next 8 bits are dummy
    SS_n=0;
    MOSI=0;
    @(negedge clk);
    MOSI=1;
    @(negedge clk);
    for(i=9;i>=0;i=i-1) begin
        MOSI=MOSI_tmp[i];
        @(negedge clk);
    end

    @(negedge clk);

    if(rx_data[9:8] !== MOSI_tmp[9:8]) begin //doesn't check on dummy 8 bits
        $display("read address doesn't work");
        $stop;
    end
    
    tx_data=8'h45; //simulating data read from the memory
    tx_valid=1;

    for(i=7;i>=0;i=i-1) begin
        @(negedge clk);
        if(MISO !== tx_data[i]) begin
            $display("read data doesn't work, specifically the converting from parallel to serial");
            $stop;
        end
        
    end


    SS_n=1;
    tx_valid=0;
    @(negedge clk);


    repeat(50) begin
        // -----------------------------------------------------------------------------
        // testing write address
        // testing rx_data is getting MOSI after 11 clock cycles
        // -----------------------------------------------------------------------------
        MOSI_tmp=$random;
        MOSI_tmp[9:8]=2'b00; //first 2 bits must be 00 
        SS_n=0;
        MOSI=0;
        @(negedge clk);
        MOSI=0;
        @(negedge clk);
        for (i=9;i>=0;i=i-1) begin
            MOSI=MOSI_tmp[i];
            @(negedge clk);
        end

        @(negedge clk);

        if(rx_data!==MOSI_tmp || rx_valid!==1) begin
            $display("Write address doesn't work");
            $stop;
        end
        SS_n=1;
        @(negedge clk);


        // -----------------------------------------------------------------------------
        // testing write data
        // -----------------------------------------------------------------------------
        MOSI_tmp=$random;
        MOSI_tmp[9:8]=2'b01; //first 2 bits must be 01
        SS_n=0;
        MOSI=0;
        @(negedge clk);
        MOSI=0;
        @(negedge clk);
        for(i=9;i>=0;i=i-1) begin
            MOSI=MOSI_tmp[i];
            @(negedge clk);
        end

        @(negedge clk);

        if(rx_data!==MOSI_tmp || rx_valid!==1) begin
            $display("Write data doesn't work");
            $stop;
        end
        SS_n=1;
        @(negedge clk);

        // -----------------------------------------------------------------------------
        // testing read address
        // -----------------------------------------------------------------------------
        MOSI_tmp=$random;
        MOSI_tmp[9:8]=2'b10; //first 2 bits must be 10
        SS_n=0;
        MOSI=0;
        @(negedge clk);
        MOSI=1;
        @(negedge clk);
        for(i=9;i>=0;i=i-1) begin
            MOSI=MOSI_tmp[i];
            @(negedge clk);
        end

        @(negedge clk);

        if(rx_data!==MOSI_tmp || rx_valid!==1) begin
            $display("read address doesn't work");
            $stop;
        end
        SS_n=1;
        @(negedge clk);

        // -----------------------------------------------------------------------------
        // testing read data
        // -----------------------------------------------------------------------------
        MOSI_tmp=$random;
        MOSI_tmp[9:8]=2'b11; //first 2 bits bust be 11. next 8 bits are dummy
        SS_n=0;
        MOSI=0;
        @(negedge clk);
        MOSI=1;
        @(negedge clk);
        for(i=9;i>=0;i=i-1) begin
            MOSI=MOSI_tmp[i];
            @(negedge clk);
        end

        @(negedge clk);

        if(rx_data[9:8] !== MOSI_tmp[9:8]) begin //doesn't check on dummy 8 bits
            $display("read address doesn't work");
            $stop;
        end

        tx_data=$random; //simulating data read from the memory
        tx_valid=1;

        for(i=7;i>=0;i=i-1) begin
            @(negedge clk);
            if(MISO !== tx_data[i]) begin
                $display("read data doesn't work, specifically the converting from parallel to serial");
                $stop;
            end
        end


        SS_n=1;
        tx_valid=0;
        @(negedge clk);

    end




    $display("Tests passed");
    $stop;

end



initial begin
    $monitor("MOSI=%h, SS_n=%b, tx_data=%h, tx_valid=%b, MISO=%b, rx_data=%h, rx_valid=%b",
        MOSI,SS_n,tx_data,tx_valid,MISO,rx_data,rx_valid);
end
endmodule