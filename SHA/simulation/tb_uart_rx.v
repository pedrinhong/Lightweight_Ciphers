module tb_uart_rx;

    reg clk;
    reg rst;
    reg rx;
    wire [7:0] data_out;
    wire data_ready;

    // Instantiate the UART receiver
    uart_rx uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data_out),
        .data_ready(data_ready)
    );

    // Clock generation (100 MHz -> 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to send UART data with correct baud timing
    task send_byte(input [7:0] byte);
        integer i;
        begin
            rx = 0;  // Start bit
            #(104160); // Start bit duration

            for (i = 0; i < 8; i = i + 1) begin
                rx = byte[i]; // Send each bit
                #(104160);    // Bit duration
            end

            rx = 1;  // Stop bit
            #(104160); // Stop bit duration
        end
    endtask

    initial begin
        $monitor("Time=%0t | rx=%b | data_out=%h | data_ready=%b", 
                 $time, rx, data_out, data_ready);

        // Initialize signals
        rst = 1;
        rx = 1; // Idle line
        #100;
        rst = 0;

        // Send test byte 0xA5 (10100101)
        #200;
        send_byte(8'hA5);

        #200000;  // Allow time to process
        if (data_ready) 
            $display("Received data: %h", data_out);
        else 
            $display("Data not received correctly.");

        $finish;
    end

endmodule
