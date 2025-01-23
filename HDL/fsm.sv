module fsm (
    input  logic uart_tx_active,
    input  logic uart_tx_done,
    input  logic clk,                   // Horloge globale
    input  logic reset,                 // Réinitialisation asynchrone
    input  logic [7:0] data_in,         // Données en entrée via UART (8 bits)
    input  logic control_in,            // Signal de contrôle pour débuter une opération
    input  logic result_ready,          // Signal indiquant que le résultat est prêt
    output logic control_out,           // Signal de contrôle pour l'UART
    output logic [7:0] data_out,        // Données en sortie via UART
    output logic cryp_decryp,           // Chiffrement (1) ou déchiffrement (0)
    output logic [7:0] k_in [7:0],      // Clés d'entrée (SIMON)
    output logic [7:0] text_in [3:0],   // Texte clair ou crypté
    input logic  [7:0] crypt_out [3:0], // Résultat chiffré ou déchiffré
    output logic led_input_commande,    
    output logic led_key_input,         
    output logic led_text_input,        
    output logic led_wait_result,       
    output logic led_output_result     
);

    // États de la FSM
    typedef enum logic [2:0] {
        INPUT_COMMANDE  = 3'b000,  
        KEY_INPUT       = 3'b001, 
        TEXT_INPUT      = 3'b010,
        WAIT_RESULT     = 3'b011,
        OUTPUT_RESULT   = 3'b100
    } state_t;

    state_t current_state, next_state;
    
    typedef enum logic [1:0] {
        INIT  = 2'b00, 
        SIMON = 2'b01,  
        SHA   = 2'b10, 
        RSA   = 2'b11
    } algo_t;


    logic [3:0] key_counter;      // Compteur pour les 8 clés
    logic [2:0] text_counter;     // Compteur pour les 4 blocs de texte
    logic [2:0] output_counter;   // Compteur pour les 4 résultats


    // Prochain état combinatoire
    always_comb begin
        next_state = current_state;
        case (current_state)
            INPUT_COMMANDE: begin
                    if (control_in) begin 
                        next_state  = (data_in[1:0] == SIMON) ? KEY_INPUT : INPUT_COMMANDE;
                        cryp_decryp = ~ (data_in[1:0] == SIMON) ? 1 : 0;
                    end 
            end

            KEY_INPUT: begin
                if (key_counter == 8)
                    next_state = TEXT_INPUT;
            end

            TEXT_INPUT: begin
                if (text_counter == 4)
                    next_state = WAIT_RESULT;
            end

            WAIT_RESULT: begin
                if (result_ready == 1)
                    next_state = OUTPUT_RESULT;
            end

            OUTPUT_RESULT: begin
                if (output_counter == 4 )
                    next_state = INPUT_COMMANDE;
            end
        endcase
    end

    // Logic séquentiel
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state <= INPUT_COMMANDE;
            key_counter <= 0;
            text_counter <= 0;
            output_counter <= 0;
            control_out <= 0;
            data_out <= 0;
        end 
        else begin
            current_state <= next_state;
            case (current_state)
                KEY_INPUT: begin
                    if (control_in) begin
                        k_in[key_counter] <= data_in;
                        key_counter <= key_counter + 1;
                    end
                end

                TEXT_INPUT: begin
                    if (control_in) begin
                        text_in[text_counter] <= data_in;
                        text_counter <= text_counter + 1;
                    end
                end

                WAIT_RESULT: begin
                    control_out <= 0;
                end

                OUTPUT_RESULT: begin
                    if (output_counter < 4) begin
                        data_out <= crypt_out[output_counter]; 
                        if (!uart_tx_active && !uart_tx_done) begin
                            // Si le module UART est inactif (prêt à envoyer un octet)
                            output_counter <= output_counter;
                            control_out <= 1; // Activer le signal de contrôle pour commencer la transmission
                        end else if (uart_tx_active && !uart_tx_done) begin
                            // Si la transmission est en cours
                        end else if (!uart_tx_active && uart_tx_done) begin
                            // Si la transmission précédente est terminée
                            output_counter <= output_counter + 1; // Incrémenter le compteur
                            control_out <= 0; // Désactiver le signal de contrôle pour le prochain cycle
                        end
                    end else begin
                        // Une fois les 4 octets envoyés, réinitialiser
                        output_counter <= 0;
                        control_out <= 0; // Assurer que le signal de contrôle est désactivé
                    end
                end     

                default: begin
                    key_counter <= 0;
                    text_counter <= 0;
                    output_counter <= 0;
                    control_out <= 0;
                end
            endcase
        end
    end

    // Assignation des LEDs
    
    assign led_input_commande = (current_state == INPUT_COMMANDE);
    assign led_key_input      = (current_state == KEY_INPUT);
    assign led_text_input     = (current_state == TEXT_INPUT);
    assign led_wait_result    = (current_state == WAIT_RESULT);
    assign led_output_result  = (current_state == OUTPUT_RESULT);

endmodule

/*

logic control_in_d, result_ready_d;   // Détection de front
logic control_in_rising, result_ready_rising;

// Détection de fronts montants
    always_ff @(posedge clk) begin
        if (reset) begin
            control_in_d <= 1'b0;
            result_ready_d <= 1'b0;
        end else begin
            control_in_d <= control_in;
            result_ready_d <= result_ready;
        end
    end

    assign control_in_rising = control_in && ~control_in_d;
    assign result_ready_rising = result_ready && ~result_ready_d;

*/