`timescale 1ns / 1ps

`include "if/uart_if.sv"

module top_level (
    input  logic clk,                   // Horloge principale
    input  logic reset,                 // Réinitialisation asynchrone
    input  logic rstn                   // Réinitialisation active basse
);

    // Interface UART
    uart_if uart_interface();           // Instanciation de l'interface UART

    // Signaux internes pour connecter UART, FSM et SIMON
    logic [7:0] data_in;                // Données UART en entrée
    logic [7:0] data_out;               // Données UART en sortie
    logic control_in;                   // Signal de contrôle UART -> FSM
    logic control_out;                  // Signal de contrôle FSM -> UART

    // Signaux pour FSM <-> SIMON
    logic cryp_decryp;                  // Signal pour choisir chiffrement/déchiffrement
    logic [15:0] k_in [3:0];            // Clés d'entrée pour SIMON
    logic [15:0] text_in [1:0];         // Texte clair ou crypté
    logic [15:0] crypt_out [1:0];       // Résultat chiffré/déchiffré
    logic result_ready;                 // Signal de résultat prêt (FSM -> SIMON)

    // Instance UART
    uart #(
        .DATA_WIDTH(8),
        .BAUD_RATE(115200),
        .CLK_FREQ(100_000_000)
    ) u_uart (
        .rxif(uart_interface.rx),       // Interface UART réception
        .txif(uart_interface.tx),       // Interface UART transmission
        .clk(clk),
        .rstn(rstn)
    );

    // Connexion des données UART pour communication avec FSM
    assign data_in    = uart_interface.rx.data;  // Données reçues via UART
    assign control_in = uart_interface.rx.valid; // Signal indiquant la réception valide

    // Instance de la FSM
    fsm u_fsm (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .control_in(control_in),
        .result_ready(result_ready),    // Signal prêt pour le résultat
        .control_out(control_out),      // Signal de contrôle pour UART
        .data_out(data_out),            // Données en sortie
        .cryp_decryp(cryp_decryp),      // Signal SIMON
        .k_in(k_in),                    // Clés pour SIMON
        .text_in(text_in),              // Texte d'entrée
        .crypt_out(crypt_out)           // Résultat SIMON
    );

    // Transmission des données de sortie FSM vers UART
    always_comb begin
        uart_interface.tx.data  = data_out;      // Données en sortie
        uart_interface.tx.valid = control_out;   // Signal de validité de la transmission
    end

    // Instance du module SIMON
    simon u_simon (
        .done(result_ready),
        .clk(clk),
        .rst(reset),
        .cryp_decryp(cryp_decryp),
        .k_in(k_in),
        .text_in(text_in),
        .crypt_out(crypt_out)
    );

endmodule
