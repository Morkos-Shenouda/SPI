module top (
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO
);
wire [9:0] rx_data;
wire rx_valid;
wire [7:0] tx_data;
wire tx_valid;

Slave s1(
    .clk(clk),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .MISO(MISO),
    .SS_n(SS_n),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .tx_data(tx_data),
    .tx_valid(tx_valid)
);

ram r1(
    .din(rx_data),
    .clk(clk),
    .rst_n(rst_n),
    .rx_valid(rx_valid),
    .dout(tx_data),
    .tx_valid(tx_valid)
)
    
endmodule