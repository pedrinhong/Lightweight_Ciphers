
`timescale 1ns / 1ps

module top_level (
    input  logic        clk,
    input  logic        resetn,
    input  logic        uart_rx_data,
    output logic        uart_tx_data,          // Données série transmises (sortie UART TX)
    output logic        led_input_commande,    // LED pour INPUT_COMMANDE
    output logic        led_key_input,         // LED pour KEY_INPUT
    output logic        led_text_input,        // LED pour TEXT_INPUT
    output logic        led_wait_result,       // LED pour WAIT_RESULT
    output logic        led_output_result,     // LED pour OUTPUT_RESULT
    output logic        [7:0] data_out_test,   // Test data output
    output logic [255:0] sha_digest,            // SHA-256 digest output
    output logic       digest_valid            // SHA-256 digest valid
);

     // Internal signals for SHA256 interface
    logic [7:0] sha_data_in;         // Data input for SHA256
    logic sha_data_ready;    

    // Signaux internes pour la communication entre la FSM, UART et SIMON
    logic [7:0] fsm_data_out;              // Données FSM vers UART
    logic       fsm_control_out;           // Signal de contrôle de la FSM vers UART
    logic [7:0] fsm_data_in;               // Données UART vers la FSM
    logic       fsm_control_in;            // Signal de réception UART vers la FSM

    logic       result_ready;              // Indicateur pour signaler que le résultat est prêt
    
    logic [7:0] k_in_fsm[7:0];                // Clés pour SIMON
    logic [7:0] text_in_fsm[3:0];             // Texte d'entrée pour SIMON
    logic [7:0] crypt_out_fsm[3:0];           // Résultat du chiffrement/déchiffrement
    
    logic       cryp_decryp;               // Indicateur pour signaler chiffrement/déchiffrement
    logic [15:0] k_in[3:0];                // Clés pour SIMON
    logic [15:0] text_in[1:0];             // Texte d'entrée pour SIMON
    logic [15:0] crypt_out[1:0];           // Résultat du chiffrement/déchiffrement
    
    // SHA 256 signals 
    
   /*             
    logic [7:0] data_in;     // Incoming UART byte
    logic data_ready;        
    logic [255:0] sha_digest;  // SHA-256 digest output
    logic digest_valid;      
    
*/

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
        crypt_out_fsm[0] = crypt_out[0][7:0];   // Bits de poids faibles (LSB) de crypt_out[0]
        crypt_out_fsm[1] = crypt_out[0][15:8];  // Bits de poids forts (MSB) de crypt_out[0]
        crypt_out_fsm[2] = crypt_out[1][7:0];   // Bits de poids faibles (LSB) de crypt_out[1]
        crypt_out_fsm[3] = crypt_out[1][15:8];  // Bits de poids forts (MSB) de crypt_out[1]
         
    end
    
    //Test avec les leds
    
    logic [28:0] counter = 0;  // Compteur pour 5 secondes (log2(500,000,000) ≈ 29 bits)
    logic [3:0] index = 0;     // Index pour alterner l'affichage (3 bits pour gérer jusqu'à 8 valeurs)
    
    // Compteur pour gérer le changement toutes les 5 secondes
    always_ff @(posedge clk) begin
        if (counter >= 500_000_000 - 1) begin  // 5 secondes avec clk = 100 MHz
            counter <= 0;
            index <= index + 1;  // Passer à la prochaine valeur
        end else begin
            counter <= counter + 1;
        end
    end
    
    // Sélection des valeurs à afficher
    always_comb begin
        case (index)
            4'd0: data_out_test = k_in_fsm[0];
            4'd1: data_out_test = k_in_fsm[1];
            4'd2: data_out_test = k_in_fsm[2];
            4'd3: data_out_test = k_in_fsm[3];
            4'd4: data_out_test = k_in_fsm[4];
            4'd5: data_out_test = k_in_fsm[5];
            4'd6: data_out_test = k_in_fsm[6];
            4'd7: data_out_test = k_in_fsm[7];
            4'd8: data_out_test = text_in_fsm[0];
            4'd9: data_out_test = text_in_fsm[1];
            4'd10: data_out_test = text_in_fsm[2];
            4'd11: data_out_test = text_in_fsm[3];
            4'd12: data_out_test = crypt_out_fsm[0];
            4'd13: data_out_test = crypt_out_fsm[1];
            4'd14: data_out_test = crypt_out_fsm[2];
            4'd15: data_out_test = crypt_out_fsm[3];
            default: data_out_test = 8'd0;           
        endcase
    end
    
    // Handle data received via UART for SHA-256
    always_ff @(posedge clk) begin
        if (~resetn) begin
            sha_data_in <= 8'd0;  // Reset the SHA data input
            sha_data_ready <= 0;  // Reset the data ready flag
        end else begin
            // Receiving data and setting up SHA256 input
            if (fsm_control_in) begin  // Assuming fsm_control_in triggers UART data reception
                sha_data_in <= fsm_data_in;   // Pass received UART data to SHA256
                sha_data_ready <= 1;          // Indicate that data is ready for SHA256
            end else begin
                sha_data_ready <= 0;          // Reset flag when no data ready
            end
        end
    end
    
    // Instantiate the UART to SHA-256 interface
    uart_sha256_interface sha_interface (
        .clk(clk),
        .rst(~resetn),                  // Active-low reset
        .data_in(sha_data_in),          // Data received via UART (to SHA256)
        .data_ready(sha_data_ready),    // Flag indicating data is ready
        .sha_digest(sha_digest),        // SHA-256 digest output
        .digest_valid(digest_valid)     // Validity flag for SHA-256 digest
    );

    // Instance de la FSM (gestion des états de l'algorithme)
    fsm u_fsm (
        .uart_tx_active(uart_tx_active),
        .uart_tx_done(uart_tx_done),
        .clk(clk),
        .reset(~resetn),
        .data_in(fsm_data_in),             // Données reçues depuis l'UART
        .control_in(fsm_control_in),       // Signal de contrôle de réception UART
        .result_ready(result_ready),       // Signal de résultat prêt
        // SHA
         
        .data_ready(sha_data_ready),        // Signal indicating data_in is valid
 //       .block_ready(block_ready),        // High when a full 512-bit block is ready
        .digest_valid(digest_valid),
 //        .sha_block(sha_block), // 512-bit output block
             
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
        .wait_data(~led_wait_result),
        .clk(clk),
        .rst(~resetn),
        .done(result_ready),               // Signal indiquant que le résultat est prêt
        .cryp_decryp(cryp_decryp),         // Signal pour choisir chiffrement ou déchiffrement
        .k_in(k_in),                       // Clés pour SIMON
        .text_in(text_in),                 // Texte d'entrée pour SIMON
        .crypt_out(crypt_out)              // Résultat du chiffrement/déchiffrement
    );

    transmitter tx(
        .clk(clk),
        .i_DV(fsm_control_out),
        .i_Byte(fsm_data_out), 
        .o_Sig_Active(uart_tx_active),
        .o_Serial_Data(uart_tx_data),
        .o_Sig_Done(uart_tx_done)
    );
    
    receiver rx(
        .clk(clk),
        .i_Serial_Data(uart_rx_data),
        .o_DV(fsm_control_in),
        .o_Byte(fsm_data_in)
    );

    /*
    uart_tx tx(
            i_Clock(clk),
            i_Tx_DV(fsm_control_out),
            i_Tx_Byte(fsm_data_out), 
            o_Tx_Active(uart_tx_active),
            o_Tx_Serial(uart_tx_data),
            o_Tx_Done(uart_tx_done)
    );
    
    uart_rx rx(
            i_Clock(clk),
            i_Rx_Serial(uart_rx_data),
            o_Rx_DV(fsm_control_in),
            o_Rx_Byte(fsm_data_in)
    );
    
    */

    // Instance du module de transmission UART (TxUnit)
    /*TxUnit u_tx_unit (
        .reset_n(resetn),                   // Active low reset
        //.send(fsm_control_out),           // Signal pour débuter l'envoi des données
        .send(1'b1),
        .clock(clk),                      // Horloge du système
        .parity_type(2'b00),              // Parité non utilisée, à définir selon besoin
        .baud_rate(2'b00),                // Baud rate à définir selon le besoin
        .data_in(8'b11111010),           // Données à envoyer via UART
        //.data_in(fsm_data_out),           // Données à envoyer via UART

        .data_tx(uart_tx_data),           // Sortie de données série
        .active_flag(uart_tx_active),     // Indicateur si transmission est en cours
        .done_flag(uart_tx_done)          // Indicateur si la transmission est terminée
    );*/

    // Instance du module de réception UART (RxUnit)
    /*RxUnit u_rx_unit (
        .reset_n(resetn),                 // Active low reset
        .data_tx(uart_rx_data),           // Données reçues via UART
        .clock(clk),                      // Horloge du système
        .parity_type(2'b00),              // Parité non utilisée, à définir selon besoin
        .baud_rate(2'b00),                // Baud rate à définir selon le besoin

        .active_flag(uart_rx_active),     // Indicateur si réception est en cours
        .done_flag(fsm_control_in),       // Indicateur si réception terminée
        .error_flag(),                    // Indicateur d'erreur (parité, start, stop)
        .data_out(fsm_data_in)            // Données reçues envoyées à la FSM
    );*/
    
endmodule
