module uart_rx (
    input wire clk,       // 100MHz clock
    input wire rst,       // Reset signal
    input wire rx,        // UART RX line
    output reg [7:0] data_out, // Received byte
    output reg data_ready // High when a full byte is received
);

    parameter BAUD_RATE = 10416;  // Cycles per bit (for 9600 baud at 100MHz)
    
    reg [13:0] baud_counter = 0;
    reg [3:0] bit_index = 0;
    reg [7:0] shift_reg;
    reg receiving = 0;
    reg rx_sync1, rx_sync2;

    // Synchronize the RX input to avoid metastability issues
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0;
            data_ready <= 0;
            receiving <= 0;
            baud_counter <= 0;
            bit_index <= 0;
        end 
        else begin
            if (!receiving && !rx_sync2) begin
                // Detected start bit (falling edge)
                receiving <= 1;
                baud_counter <= BAUD_RATE / 2;  // Sample mid-bit
                bit_index <= 0;
                data_ready <= 0;
            end 
            else if (receiving) begin
                if (baud_counter == 0) begin
                    baud_counter <= BAUD_RATE;  // Reset baud counter
                    
                    if (bit_index < 8) begin
                        shift_reg[bit_index] <= rx_sync2;  // Capture RX data
                        bit_index <= bit_index + 1;
                    end 
                    else begin
                        // Stop bit received, finalize data
                        receiving <= 0;
                        data_out <= shift_reg;
                        data_ready <= 1;
                    end
                end 
                else begin
                    baud_counter <= baud_counter - 1;
                end
            end 
            else begin
                data_ready <= 0; // Clear data_ready when not receiving
            end
        end
    end

endmodule
