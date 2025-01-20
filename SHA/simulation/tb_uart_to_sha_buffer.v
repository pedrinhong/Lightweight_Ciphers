module tb_uart_to_sha_buffer;

    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg data_ready;
    wire [511:0] sha_block;
    wire block_ready;

    // Instantiate the buffer module
    uart_to_sha_buffer uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_ready(data_ready),
        .sha_block(sha_block),
        .block_ready(block_ready)
    );

    // Clock generation (100 MHz -> 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        rst = 1;
        data_in = 0;
        data_ready = 0;
        #20 rst = 0;

        // Send 64 bytes (0x01, 0x02, ..., 0x40)
        repeat (64) begin
            #10 data_in = $random % 256;  // Simulate random byte data
            data_ready = 1;
            #10 data_ready = 0;
        end

        #50;
        if (block_ready) begin
            $display("Test Passed: 512-bit block received.");
        end else begin
            $display("Test Failed: Block not ready.");
        end

        $finish;
    end

endmodule
