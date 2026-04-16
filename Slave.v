module Slave #(
    parameter width=8
) (
    input clk,
    input rst_n,

    input MOSI,
    input SS_n,
    input [width-1:0] tx_data,
    input tx_valid,

    output reg MISO,
    output reg [width+1:0] rx_data,
    output reg rx_valid
);

localparam IDLE=0;
localparam CHK_CMD=1;
localparam WRITE=2;
localparam READ_ADD=3;
localparam READ_DATA=4;

(* fsm_encoding = "sequential" *)
reg [2:0] cs,ns;
integer counter1;
integer counter2;
reg has_read_address;

always @(posedge clk ) begin
    if(!rst_n) begin
        cs<=0;
        has_read_address<=0;
    end
    else begin 
        cs<=ns;
        if (cs==READ_ADD) has_read_address<=1;
        else if(cs==READ_DATA) has_read_address<=0;
    end
end

always @(*) begin
    case (cs)
        IDLE:
            if(SS_n==1) ns=IDLE;
            else ns=CHK_CMD;
        
        CHK_CMD:
            if(SS_n==1) ns=IDLE;
            else if(MOSI==0) ns=WRITE;
            else if(!has_read_address) ns=READ_ADD;
            else ns=READ_DATA;
        
        WRITE:
            if(SS_n==1) ns=IDLE;
            else ns=WRITE;
        
        READ_ADD: begin
            if(SS_n==1) ns=IDLE;
            else ns=READ_ADD;
        end

        READ_DATA: begin
            if(SS_n==1) ns=IDLE;
            else ns=READ_DATA;
        end

        default:
            ns=IDLE;
    endcase
end

always @(posedge clk) begin
    if(!rst_n) begin
        MISO<=0;
        rx_data<=0;
        rx_valid<=0;
        counter1<=0;
        counter2<=0;
    end else begin
        case (cs)
            WRITE: 
                if(counter1<width+2) begin
                    rx_data[width-counter1+1]<=MOSI;
                    counter1<=counter1+1;
                end 
                else rx_valid<=1;

            READ_ADD:
                if(counter1<width+2) begin
                    rx_data[width-counter1+1]<=MOSI;
                    counter1<=counter1+1;
                end
                else rx_valid<=1;

            READ_DATA:
                if(counter1<width+2) begin
                    rx_data[width-counter1+1]<=MOSI;
                    counter1<=counter1+1;
                end
                else begin
                    rx_valid<=1;
                    if(tx_valid) begin
                        if(counter2<width) begin
                            MISO<=tx_data[width-counter2-1];
                            counter2<=counter2+1;
                        end
                    end
                end
            
            default: begin
                MISO<=0;
                rx_valid<=0;
                rx_data<=0;
                counter1<=0;
                counter2<=0;
            end

        endcase
    end
end
    
endmodule