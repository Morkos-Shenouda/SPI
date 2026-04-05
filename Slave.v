module Slave (MOSI, MISO, SS_n, rx_data, rx_valid, tx_data, tx_valid, clk, rst_n);

    parameter IDLE = 3'b000;
    parameter CHK_CMD = 3'b001;
    parameter WRITE = 3'b010;
    parameter READ_ADD = 3'b011;
    parameter READ_DATA = 3'b100;

    input MOSI, SS_n, clk, rst_n, tx_valid;
    input [7:0] tx_data;

    output reg rx_valid, MISO;
    output reg [9:0] rx_data;

    // internal signal to know if read address is recieved or not
    reg add_recieved;

    // internal counters for conversion
    reg [3:0] s2p_count;
    reg [3:0] p2s_count;

    // states
    (* fsm_encoding = "sequential" *)
    reg[2:0] cs,ns;

    // reset logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs <= IDLE;
            add_recieved <= 0;
            s2p_count <= 0;
            p2s_count <= 0;
            rx_valid <= 0;
            rx_data <= 0;
            MISO <= 0;
        end
        else
            cs <= ns;
    end

    // next state logic
    always @(cs, SS_n, MOSI) begin
        case (cs) 

            IDLE:
                if (!SS_n)
                    ns = CHK_CMD;
                else
                    ns = IDLE;
            
            CHK_CMD:
                if (SS_n)
                    ns = IDLE;
                else if (!SS_n && !MOSI) begin
                    ns = WRITE;
                    s2p_count = 10;
                end
                else if (!SS_n && MOSI && !add_recieved) begin
                    ns = READ_ADD;
                    s2p_count = 10;
                    add_recieved = 1;
                end
                else if (!SS_n && MOSI && add_recieved) begin
                    ns = READ_DATA;
                    s2p_count = 10;
                    p2s_count = 8;
                end

            WRITE:
                if (SS_n)
                    ns = IDLE;
                else if (!SS_n && s2p_count)
                    ns = WRITE;

            READ_ADD:
                if (SS_n)
                    ns = IDLE;
                else if (!SS_n && s2p_count) 
                    ns = READ_ADD;
            
            READ_DATA:
                if (SS_n)
                    ns = IDLE;
                else if (!SS_n && (s2p_count || p2s_count))
                    ns = READ_DATA;

        endcase
    end

    // output logic
    always @(posedge clk) begin
        case (cs)

            IDLE:
                rx_valid = 0;

            WRITE: begin
                if (s2p_count) begin
                    rx_data = (rx_data << 1) + MOSI;
                end
                s2p_count = s2p_count - 1;
                if (!s2p_count)
                    rx_valid <= 1;
            end

            READ_ADD: begin
                s2p_count = s2p_count - 1;
                if (s2p_count) begin
                    rx_data = (rx_data << 1) + MOSI;
                end
                else 
                    rx_valid = 1;
            end

            READ_DATA: begin
                s2p_count = s2p_count - 1;
                if (s2p_count) begin
                    rx_data = (rx_data << 1) + MOSI;
                end
                else 
                    rx_valid = 1;

                if (tx_valid && p2s_count) begin
                    MISO = tx_data[p2s_count - 1];
                    p2s_count = p2s_count - 1;
                    if (!p2s_count)
                        add_recieved = 0;
                end
            end

        endcase
    end
endmodule
