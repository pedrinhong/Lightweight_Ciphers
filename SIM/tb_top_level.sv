
`timescale 1ns / 1ps


module tb_top_level;

    // Déclaration des signaux
    logic clk;
    logic resetn;
    logic uart_rx_data;
    logic uart_tx_data;
    logic led_input_commande;
    logic led_key_input;
    logic led_text_input;
    logic led_wait_result;
    logic led_output_result;
    logic [7:0] data_out;

    // Période d'horloge
    parameter CLK_PERIOD = 10ns;

    // Période d'un bit pour baud rate 4800
    parameter BIT_PERIOD = 870ns;

    // Instanciation du DUT (Device Under Test)
    top_level dut (
        .clk(clk),
        .resetn(resetn),
        .uart_rx_data(uart_rx_data),
        .uart_tx_data(uart_tx_data),
        .led_input_commande(led_input_commande),
        .led_key_input(led_key_input),
        .led_text_input(led_text_input),
        .led_wait_result(led_wait_result),
        .led_output_result(led_output_result),
        .data_out_test(data_out)
    );

    // Génération de l'horloge
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Stimulus
    initial begin
        // Initialisation
        resetn = 0;
        uart_rx_data = 1; // Ligne UART idle (haut)
        #(10 * CLK_PERIOD);
        resetn = 1;

        // Envoi de la commande
        send_byte(8'h01); // Commande pour SIMON
        #(100 * CLK_PERIOD);

        // Envoi des clés
        send_word(16'h0100); // k1
        #(100 * CLK_PERIOD);
        send_word(16'h0908); // k2
        #(100 * CLK_PERIOD);
        send_word(16'h1110); // k3
        #(100 * CLK_PERIOD);
        send_word(16'h1918); // k4
        #(100 * CLK_PERIOD);

        // Envoi des données à crypter
        send_word(16'h6565); // text0
        #(100 * CLK_PERIOD);
        send_word(16'h6877); // text1
        #(100 * CLK_PERIOD);

        // Fin de la simulation
        #(200 * CLK_PERIOD);
        $stop;
    end

    // Tâche pour envoyer un octet via UART
    task send_byte(input logic [7:0] byte_data);
        integer i;
        begin
            // Start bit
            uart_rx_data = 0;
            #(BIT_PERIOD);
            // Envoi des bits de données (LSB d'abord)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx_data = byte_data[i];
                #(BIT_PERIOD);
            end
            // Stop bit
            uart_rx_data = 1;
            #(BIT_PERIOD);
        end
    endtask

    // Tâche pour envoyer un mot de 16 bits via UART
    task send_word(input logic [15:0] word_data);
        begin
            send_byte(word_data[7:0]);  // LSB
            send_byte(word_data[15:8]); // MSB
        end
    endtask


endmodule
