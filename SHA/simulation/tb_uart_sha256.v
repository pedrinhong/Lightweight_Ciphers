/*
module tb_uart_sha256_interface;

    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg data_ready;
    wire [255:0] sha_digest;
    wire digest_valid;

    // Instantiate the top-level UART-SHA interface
    uart_sha256_interface uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_ready(data_ready),
        .sha_digest(sha_digest),
        .digest_valid(digest_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end

    // Test sequence
    initial begin
        rst = 1;
        data_in = 0;
        data_ready = 0;
        #20 rst = 0;

        // Simulate sending 64 bytes of data (e.g., 0x01, 0x02, ... 0x40)
        repeat (64) begin
            #10 data_in = $random % 256;  // Random byte data
            data_ready = 1;
            #10 data_ready = 0;
        end

        // Wait for digest to be ready
        wait (digest_valid);
        #10;
        $display("SHA-256 Digest: %h", sha_digest);

        $finish;
    end

endmodule
*/

module tb_uart_sha256_interface;

    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg data_ready;
    wire [255:0] sha_digest;
    wire digest_valid;

    // Instantiate the top-level UART-SHA interface
    uart_sha256_interface uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_ready(data_ready),
        .sha_digest(sha_digest),
        .digest_valid(digest_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end

    // Test sequence
    initial begin
        rst = 1;
        data_in = 0;
        data_ready = 0;
        #20 rst = 0;

        // Send fixed block of data (616263800000...00000018)
        //data_in = 8'h00; #10 data_ready = 1; #10 data_ready = 0; // this will be ignored, just to start the input data
        data_in = 8'h61; #10 data_ready = 1; #10 data_ready = 0;
        data_in = 8'h62; #10 data_ready = 1; #10 data_ready = 0;
        data_in = 8'h63; #10 data_ready = 1; #10 data_ready = 0;
        data_in = 8'h80; #10 data_ready = 1; #10 data_ready = 0;
        repeat (59) begin
            data_in = 8'h00; #10 data_ready = 1; #10 data_ready = 0;
        end
        data_in = 8'h18; #10 data_ready = 1; #10 data_ready = 0;

        // Wait for digest to be ready
        wait (digest_valid);
        #10;
        $display("SHA-256 Digest: %h", sha_digest);

        $finish;
    end

endmodule

/* 
Input data:
Input = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
Input = abc (when testing online) this is the input

Expected result
RES = 256'hBA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD;

*/
