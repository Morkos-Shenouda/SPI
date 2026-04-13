module top #(
    parameter MEM_WIDTH=8,
    parameter MEM_DEPTH=256
)(
    input clk,
    input rst_n,
    input SS_n,
    input MOSI,
    output MISO
);
wire [MEM_WIDTH+1:0] rx_data;
wire rx_valid;
wire [MEM_WIDTH-1:0] tx_data;
wire tx_valid;

Slave #(
    .width(MEM_WIDTH)
)
s1(
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

RAM #(
    .MEM_WIDTH(MEM_WIDTH),
    .MEM_DEPTH(MEM_DEPTH)
)
ram(
    .din(rx_data),
    .clk(clk),
    .rst(rst_n),
    .rx_valid(rx_valid),
    .dout(tx_data),
    .tx_valid(tx_valid)
);
    
endmodule