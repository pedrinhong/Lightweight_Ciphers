module uart_sha256_interface (
    input wire clk,           
    input wire rst,              
    input wire [7:0] data_in,     // Incoming UART byte
    input wire data_ready,        

    output wire [255:0] sha_digest,  // SHA-256 digest output
    output wire digest_valid         
);

    // Internal signals
    wire [511:0] sha_block;       // 512-bit input block to SHA core
    wire block_ready;             
    reg sha_init;                 // start SHA-256 calculation
    wire sha_ready;             

    // Instantiate the UART to 512-bit buffer
    uart_to_sha_buffer buffer_inst (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_ready(data_ready),
        .sha_block(sha_block),
        .block_ready(block_ready)
    );

    // Instantiate the SHA-256 core
    sha256_core sha_inst (
        .clk(clk),
        .reset_n(~rst),           // Active-low reset
        .init(sha_init),
        .next(1'b0),              // No continuous processing, only initial calculation
        .mode(1'b1),              // Default SHA-256 mode (not SHA-224)
        .block(sha_block),
        .ready(sha_ready),
        .digest(sha_digest),
        .digest_valid(digest_valid)
    );

    // SHA control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sha_init <= 0;
        end else if (block_ready && sha_ready) begin
            sha_init <= 1;  // Start SHA processing when block is ready and core is available
        end else begin
            sha_init <= 0;
        end
    end

endmodule
