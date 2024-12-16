`timescale 1ns / 1ps

module fsm (
    input  logic clk,                   // Horloge
    input  logic reset,                 // Réinitialisation asynchrone
    input  logic [7:0] data_in,         // Données en entrée via UART (8 bits)
    input  logic control_in,            // Signal de contrôle pour débuter une opération
    input  logic result_ready,          // Signal indiquant que le résultat est prêt
    output logic control_out,           // Signal de contrôle pour l'UART
    output logic [7:0] data_out,        // Données en sortie via UART
    output logic cryp_decryp,           // Chiffrement (1) ou déchiffrement (0)
    output logic [15:0] k_in [3:0],     // Clés d'entrée (SIMON)
    output logic [15:0] text_in [1:0],  // Texte clair ou crypté
    output logic [15:0] crypt_out [1:0] // Résultat chiffré ou déchiffré
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

    // Définition de l'algorithme sélectionné
    typedef enum logic [1:0] {
        SIMON = 2'b00,  
        SHA   = 2'b01, 
        RSA   = 2'b10
    } algo_t;

    algo_t commande;

    // Compteurs pour les entrées et sorties
    logic [3:0] key_counter;    // Compteur pour les 4 clés
    logic [1:0] text_counter;   // Compteur pour les 2 blocs de texte
    logic [1:0] output_counter; // Compteur pour les sorties

    // Logic combinatoire pour déterminer le prochain état
    always_comb begin
        // Par défaut, on reste dans l'état actuel
        next_state = current_state;

        case (current_state)
            INPUT_COMMANDE: begin
                if (control_in) begin
                    commande = algo_t'(data_in[1:0]);  // Cast explicite de data_in vers algo_t
                    if (commande == SIMON)
                        next_state = KEY_INPUT;
                end
            end

            KEY_INPUT: begin
                if (key_counter == 4)  // 4 clés reçues
                    next_state = TEXT_INPUT;
            end

            TEXT_INPUT: begin
                if (text_counter == 2)  // 2 blocs de texte reçus
                    next_state = WAIT_RESULT;
            end

            WAIT_RESULT: begin
                if (result_ready)  // Signal indiquant que le résultat est prêt
                    next_state = OUTPUT_RESULT;
            end

            OUTPUT_RESULT: begin
                if (output_counter == 2)
                    next_state = INPUT_COMMANDE;  // Retour à l'état initial
            end

            default: next_state = INPUT_COMMANDE;
        endcase
    end

    // Logic séquentiel pour mettre à jour l'état et les registres
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= INPUT_COMMANDE;
            key_counter <= 0;
            text_counter <= 0;
            output_counter <= 0;
            control_out <= 0;
        end else begin
            current_state <= next_state;

            case (current_state)
                KEY_INPUT: begin
                    if (key_counter < 4) begin
                        k_in[key_counter] <= {data_in, data_in};  // 16 bits à partir de data_in
                        key_counter <= key_counter + 1;
                    end
                end

                TEXT_INPUT: begin
                    if (text_counter < 2) begin
                        text_in[text_counter] <= {data_in, data_in};  // 16 bits pour le texte
                        text_counter <= text_counter + 1;
                    end
                end

                WAIT_RESULT: begin
                    control_out <= 0;  // Désactiver le signal UART en attente
                end

                OUTPUT_RESULT: begin
                    data_out <= crypt_out[output_counter][7:0];  // Envoi des 8 bits de résultat
                    control_out <= 1;  // Activer le signal de transmission
                    output_counter <= output_counter + 1;
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

endmodule
