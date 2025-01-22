/*
`timescale 1ns / 1ps

module tb_sha256;

    // Paramètres d'horloge
    reg clk;
    reg resetn;
    
    // Signaux de la top-level module
    reg uart_rx_data;           // UART received data
    wire uart_tx_data;          // UART transmitted data
    wire led_input_commande;    // LED for input command
    wire led_key_input;         // LED for key input
    wire led_text_input;        // LED for text input
    wire led_wait_result;       // LED for waiting result
    wire led_output_result;     // LED for output result
    wire [7:0] data_out_test;   // Data output for testing
    wire [255:0] sha_digest;    // SHA-256 digest output
    wire digest_valid;          // SHA-256 digest valid flag

    // Instantiation of the top-level module
    top_level uut (
        .clk(clk),
        .resetn(resetn),
        .uart_rx_data(uart_rx_data),
        .uart_tx_data(uart_tx_data),
        .led_input_commande(led_input_commande),
        .led_key_input(led_key_input),
        .led_text_input(led_text_input),
        .led_wait_result(led_wait_result),
        .led_output_result(led_output_result),
        .data_out_test(data_out_test),
        .sha_digest(sha_digest),
        .digest_valid(digest_valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock period: 10 ns
    end

    // Reset logic
    initial begin
        resetn = 0;
        #15 resetn = 1;  // Release reset after 15 ns
    end
    
    // Stimulus: Test sequence
    initial begin
        // Initialize signals
        uart_rx_data = 0; 

        @(posedge resetn);  // Wait for reset to be released

        // === INPUT_COMMANDE ===
        $display("=== INPUT_COMMANDE ===");
        uart_rx_data = 1;  // Simulate a command for SHA256
        #10;
        uart_rx_data = 0;
        #10;
        
        // === KEY_INPUT ===
        $display("=== KEY_INPUT ===");
        // Send key data (example 256-bit key split into 8 bits per transmission)
        uart_rx_data = 1;  // Simulate key byte transmission
        #10;
        uart_rx_data = 0;
        #10;
        // Repeat for all key bytes (key length could be 256 bits, split into 8-bit parts)

        // === TEXT_INPUT ===
        $display("=== TEXT_INPUT ===");
        // Send text data (example input message for SHA256)
        uart_rx_data = 1;  // Simulate text byte transmission
        #10;
        uart_rx_data = 0;
        #10;
        // Repeat for all text bytes (input length depends on the test case)

        // === WAIT_RESULT ===
        $display("=== WAIT_RESULT ===");
        #50; // Wait for SHA256 computation to complete

        // === OUTPUT_RESULT ===
        $display("=== OUTPUT_RESULT ===");
        repeat (8) begin
            @(posedge clk);
            $display("Output SHA256 Digest: %h", sha_digest);
        end

        // Finish test
        $display("=== TEST COMPLETED ===");
        $stop;
    end

    // Monitor signals during the test
    always @(posedge clk) begin
        $display("Time: %0t | UART Data In: %b | SHA256 Digest Valid: %b | SHA256 Digest: %h",
                 $time, uart_rx_data, digest_valid, sha_digest);
    end

endmodule
*/
`timescale 1ns / 1ps

module tb_fsm_sha();

    reg clk;
    reg reset;
    reg control_in;
    reg uart_tx_active;
    reg uart_tx_done;
    reg digest_valid;
    reg [7:0] data_in;
    wire control_out;
    wire [7:0] data_out;
    wire [7:0] data_sha_in;
    
    // Instantiate the FSM module
    fsm uut (
        .clk(clk),
        .reset(reset),
        .control_in(control_in),
        .uart_tx_active(uart_tx_active),
        .uart_tx_done(uart_tx_done),
        .digest_valid(digest_valid),
        .data_in(data_in),
        .control_out(control_out),
        .data_out(data_out),
        .data_sha_in(data_sha_in)
    );

    // Clock generation
    always #5 clk = ~clk;

    // 512-bit input data for SHA (in bytes)
    reg [7:0] sha_input [0:63];  // 64 bytes (512 bits)

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        control_in = 0;
        uart_tx_active = 0;
        uart_tx_done = 0;
        digest_valid = 0;
        data_in = 0;

        // Reset sequence
        #20 reset = 0;
        #20 control_in = 1;

        // Load the 512-bit input block
        sha_input[0] = 8'h63;  // 'c'
        sha_input[1] = 8'h62;  // 'b'
        sha_input[2] = 8'h61;  // 'a'
        sha_input[3] = 8'h80;  // '80'
        sha_input[4] = 8'h00;
        sha_input[5] = 8'h00;
        sha_input[6] = 8'h00;
        sha_input[7] = 8'h00;
        // Fill remaining with zeros until the last byte
        for (int i = 8; i < 63; i = i + 1) begin
            sha_input[i] = 8'h00;
        end
        sha_input[63] = 8'h18; // Last byte

        // Provide SHA input bytes one by one
        for (int i = 0; i < 64; i = i + 1) begin
            data_in = sha_input[i];
            #10; // Wait for FSM to process
        end

        control_in = 0;  // End input phase

        // Simulate SHA digest processing wait
        #100 digest_valid = 1;  // Simulate digest ready

        #20 digest_valid = 0;

        // Simulate UART transmission of output
        for (int i = 0; i < 32; i = i + 1) begin
            uart_tx_active = 0;
            uart_tx_done = 1;
            #10;
            uart_tx_done = 0;
            #10;
        end

        #100;
        $finish;
    end

    // Monitor important signals
    initial begin
        $monitor("Time=%0t | State=%b | data_sha_in=%h | control_out=%b | data_out=%h",
                 $time, uut.current_state, data_sha_in, control_out, data_out);
    end

endmodule

