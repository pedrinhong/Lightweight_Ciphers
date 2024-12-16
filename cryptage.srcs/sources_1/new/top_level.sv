`timescale 1ns / 1ps

module top_level (
    input  logic        clk,                   // Horloge
    input  logic        resetn,                // Réinitialisation asynchrone active haute
    input  logic        uart_rx_data,          // Données série reçues (entrée UART RX)
    output logic        uart_tx_data,          // Données série transmises (sortie UART TX)
    output logic        led_input_commande,    // LED pour INPUT_COMMANDE
    output logic        led_key_input,         // LED pour KEY_INPUT
    output logic        led_text_input,        // LED pour TEXT_INPUT
    output logic        led_wait_result,       // LED pour WAIT_RESULT
    output logic        led_output_result,     // LED pour OUTPUT_RESULT
    //output logic  [15:0] data_rx_uart_test
    output logic        done_rx,
    output logic        result_ready
);

    //logic [7:0] send_uart_test = 8'd2;  // Initialise à 2 directement


    // Signaux internes pour la communication entre la FSM, UART et SIMON
    logic [7:0] fsm_data_out;              // Données FSM vers UART
    logic       fsm_control_out;           // Signal de contrôle de la FSM vers UART
    logic [7:0] fsm_data_in;               // Données UART vers la FSM
    logic       fsm_control_in;            // Signal de réception UART vers la FSM

    //logic       result_ready;              // Indicateur pour signaler que le résultat est prêt
    
    logic [7:0] k_in_fsm[7:0];                // Clés pour SIMON
    logic [7:0] text_in_fsm[3:0];             // Texte d'entrée pour SIMON
    logic [7:0] crypt_out_fsm[3:0];           // Résultat du chiffrement/déchiffrement
    
    logic       cryp_decryp;               // Indicateur pour signaler chiffrement/déchiffrement
    logic [15:0] k_in[3:0];                // Clés pour SIMON
    logic [15:0] text_in[1:0];             // Texte d'entrée pour SIMON
    logic [15:0] crypt_out[1:0];           // Résultat du chiffrement/déchiffrement

    // Modules UART pour transmission et réception de données série
    wire uart_tx_done;
    wire uart_rx_done;
    wire uart_tx_active;
    wire uart_rx_active;
        
    always_comb begin
        // Recombinaison des clés (k_in) à partir des k_in_fsm
        k_in[0] = {k_in_fsm[1], k_in_fsm[0]};  // Clé 0 : combine MSB et LSB
        k_in[1] = {k_in_fsm[3], k_in_fsm[2]};  // Clé 1
        k_in[2] = {k_in_fsm[5], k_in_fsm[4]};  // Clé 2
        k_in[3] = {k_in_fsm[7], k_in_fsm[6]};  // Clé 3
    
        // Recombinaison du texte d'entrée (text_in) à partir de text_in_fsm
        text_in[0] = {text_in_fsm[1], text_in_fsm[0]};  // Texte 0
        text_in[1] = {text_in_fsm[3], text_in_fsm[2]};  // Texte 1
    
        // Découpage des valeurs 16 bits de crypt_out en valeurs 8 bits dans crypt_out_fsm
        //crypt_out_fsm[0] = crypt_out[0][7:0];   // Bits de poids faibles (LSB) de crypt_out[0]
        //crypt_out_fsm[1] = crypt_out[0][15:8];  // Bits de poids forts (MSB) de crypt_out[0]
        //crypt_out_fsm[2] = crypt_out[1][7:0];   // Bits de poids faibles (LSB) de crypt_out[1]
        //crypt_out_fsm[3] = crypt_out[1][15:8];  // Bits de poids forts (MSB) de crypt_out[1]
        
        crypt_out_fsm[0] = 8'b00010000;  
        crypt_out_fsm[1] = 8'b01111001;  
       
        crypt_out_fsm[2] = 8'b01001101;  
        crypt_out_fsm[3] = 8'b00101010;  

    
    end
    
    
    
    // Instance de la FSM (gestion des états de l'algorithme)
    fsm u_fsm (
        .clk(clk),
        .reset(~resetn),
        .data_in(fsm_data_in),             // Données reçues depuis l'UART
        .control_in(fsm_control_in),       // Signal de contrôle de réception UART
        .result_ready(result_ready),       // Signal de résultat prêt
        //.result_ready(1'b1),                // Signal de résultat prêt
        .control_out(fsm_control_out),     // Signal de contrôle pour l'UART
        .data_out(fsm_data_out),           // Données transmises vers UART
        .cryp_decryp(cryp_decryp),         // Signal pour SIMON (chiffrement/déchiffrement)
        .k_in(k_in_fsm),                       // Clés d'entrée pour SIMON
        .text_in(text_in_fsm),                 // Texte d'entrée pour SIMON
        .crypt_out(crypt_out_fsm),             // Résultat du chiffrement/déchiffrement
        .led_input_commande(led_input_commande),
        .led_key_input(led_key_input),
        .led_text_input(led_text_input),
        .led_wait_result(led_wait_result),
        .led_output_result(led_output_result)
    );

    // Instance du module SIMON (algorithme de chiffrement/déchiffrement)
    simon u_simon (
        .clk(clk),
        .rst(~resetn),
        .done(result_ready),               // Signal indiquant que le résultat est prêt
        .cryp_decryp(cryp_decryp),         // Signal pour choisir chiffrement ou déchiffrement
        .k_in(k_in),                       // Clés pour SIMON
        .text_in(text_in),                 // Texte d'entrée pour SIMON
        .crypt_out(crypt_out)              // Résultat du chiffrement/déchiffrement
    );

    // Instance du module de transmission UART (TxUnit)
    TxUnit u_tx_unit (
        .reset_n(resetn),                // Active low reset
        .send(fsm_control_out),           // Signal pour débuter l'envoi des données
        //.send(1'b1),           // Signal pour débuter l'envoi des données
        
        .clock(clk),                      // Horloge du système
        .parity_type(2'b00),              // Parité non utilisée, à définir selon besoin
        .baud_rate(2'b00),                // Baud rate à définir selon le besoin
        .data_in(fsm_data_out),           // Données à envoyer via UART
        //.data_in(send_uart_test),           // Données à envoyer via UART

        .data_tx(uart_tx_data),           // Sortie de données série
        .active_flag(uart_tx_active),     // Indicateur si transmission est en cours
        .done_flag(uart_tx_done)          // Indicateur si la transmission est terminée
    );

    // Instance du module de réception UART (RxUnit)
    RxUnit u_rx_unit (
        .reset_n(resetn),                // Active low reset
        .data_tx(uart_rx_data),           // Données reçues via UART
        .clock(clk),                      // Horloge du système
        .parity_type(2'b00),              // Parité non utilisée, à définir selon besoin
        .baud_rate(2'b00),                // Baud rate à définir selon le besoin

        .active_flag(uart_rx_active),     // Indicateur si réception est en cours
        .done_flag(fsm_control_in),         // Indicateur si réception terminée
        .error_flag(),                    // Indicateur d'erreur (parité, start, stop)
        .data_out(fsm_data_in)            // Données reçues envoyées à la FSM
    );
    
//always_comb begin
    //data_rx_uart_test <= k_in[0][15:0];  // Bits de poids faibles de text_in[0]
    //done_rx <= fsm_control_in;
//end

    
endmodule



/*`timescale 1ns / 1ps

module top_level (
    input  logic        clk,                   // Horloge
    input  logic        resetn,                // Réinitialisation asynchrone active haute
    input  logic        uart_rx_data,          // Données série reçues (entrée UART RX)
    output logic        uart_tx_data,          // Données série transmises (sortie UART TX)
    output logic        led_input_commande,    // LED pour INPUT_COMMANDE
    output logic        led_key_input,         // LED pour KEY_INPUT
    output logic        led_text_input,        // LED pour TEXT_INPUT
    output logic        led_wait_result,       // LED pour WAIT_RESULT
    output logic        led_output_result      // LED pour OUTPUT_RESULT
);

    // Signaux internes entre FSM, UART et SIMON
    
    logic [7:0] fsm_data_out;              // Données FSM vers UART
    logic       fsm_control_out;           // Signal de contrôle FSM -> UART
    logic [7:0] fsm_data_in;               // Données UART vers FSM
    logic       fsm_control_in;            // Signal de réception UART -> FSM

    logic       result_ready;              // Indicateur de résultat prêt
    logic       cryp_decryp;               // Chiffrement/déchiffrement (FSM -> SIMON)
    logic [15:0] k_in[3:0];                // Clés pour SIMON
    logic [15:0] text_in[1:0];             // Texte d'entrée pour SIMON
    logic [15:0] crypt_out[1:0];           // Texte chiffré/déchiffré


    // Instance de la FSM
    fsm u_fsm (
        .clk(clk),
        .reset(resetn),
        .data_in(fsm_data_in),             // Données reçues depuis l'UART
        .control_in(fsm_control_in),       // Signal de contrôle de réception UART
        .result_ready(result_ready),       // Signal prêt pour résultat SIMON
        .control_out(fsm_control_out),     // Signal de validité des données en sortie
        .data_out(fsm_data_out),           // Données transmises vers UART
        .cryp_decryp(cryp_decryp),         // Signal pour SIMON (chiffrement/déchiffrement)
        .k_in(k_in),                       // Clés SIMON
        .text_in(text_in),                 // Texte d'entrée pour SIMON
        .crypt_out(crypt_out),             // Résultat de SIMON
        .led_input_commande(led_input_commande),
        .led_key_input(led_key_input),     
        .led_text_input(led_text_input),    
        .led_wait_result(led_wait_result),   
        .led_output_result(led_output_result)  
        
    );

    // Instance du module SIMON (chiffrement/déchiffrement)
    simon u_simon (
        .clk(clk),
        .rst(resetn),
        .done(result_ready),               // Signal de résultat prêt
        .cryp_decryp(cryp_decryp),         // Chiffrement/déchiffrement
        .k_in(k_in),                       // Clés d'entrée
        .text_in(text_in),                 // Texte clair ou chiffré
        .crypt_out(crypt_out)              // Résultat du chiffrement/déchiffrement
    );


    
    ila_0 u_ila (
        .clk    (clk),
        .probe0 (uart_rx_data),
        .probe1 (uart_tx_data)
    );

endmodule*/
