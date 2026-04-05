module Slave (MOSI,MISO,SS_n,rx_data,rx_valid,tx_data,tx_valid);
input MOSI,MISO,SS_n,clk,rst_n,tx_valid;
input reg [7:0]tx_data;
output rx_valid;
output reg [9:0] rx_data;

//internal signal to know if Read_address is recieved or not
wire Add_recieved;

// states
reg[2:0] cs,ns;
//sequential encoding
parameter STATE_IDLE = 3'b000;
parameter STATE_CHK_CMD = 3'b001
parameter STATE_WRITE = 3'b010;
parameter STATE_READ_ADD = 3'b011;
parameter STATE_READ= 3'b100;




//State memory

always@(posedge clk or rst)begin
    if (rst)
        cs <= 3'b000;
    else
        cs <= ns;
 end

 always@(posedge clk)begin
    if(SS_n==0)begin
        if(cs==3'b000)
            ns<=3'b001; // go to check command
        else if(cs==3'b001 && MOSI==0)  //write operation
            ns<=3'b010;
        else  











