module uart_to_sha_buffer (
    input wire clk,              // System clock
    input wire rst,              // System reset
    input wire [7:0] data_in,     // Incoming UART byte
    input wire data_ready,        // Signal indicating data_in is valid
    output reg [511:0] sha_block, // 512-bit output block
    output reg block_ready        // High when a full 512-bit block is ready
);

    reg [8:0] byte_count;          // Counter to track received bytes (9 bits to hold 64)
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sha_block <= 512'b0;   // Clear the output buffer
            byte_count <= 0;
            block_ready <= 0;
        end else begin
            if (data_ready) begin
                // Shift the incoming byte into the block (MSB first)
                sha_block <= {sha_block[503:0], data_in}; 
                byte_count <= byte_count + 1;
                block_ready <= 0;  // Clear block_ready until full block is received

                // Check if full block (64 bytes = 512 bits) is received
                if (byte_count == 63) begin
                    block_ready <= 1;
                    byte_count <= 0;  // Reset counter for next block
                end
            end
        end
    end

endmodule
