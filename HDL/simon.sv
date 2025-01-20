`timescale 1ns / 1ps

module simon(
    output logic done,
    input  logic wait_data,
    input  logic clk,                     // Horloge principale
    input  logic rst,                     // Réinitialisation asynchrone
    input  logic cryp_decryp,             // Signal pour choisir chiffrement (1) ou déchiffrement (0)
    input  logic [15:0] k_in[3:0],        // Les 4 clés initiales (16 bits chacune)
    input  logic [15:0] text_in[1:0],     // Texte clair ou crypté (2 blocs de 16 bits)
    output logic [15:0] crypt_out[1:0]    // Texte chiffré ou déchiffré (2 blocs de 16 bits)
);

    // Signaux internes
    logic sel;
    logic [15:0] data_in[1:0];
    logic key_ready[31:0];                // Signal de préparation des clés
    logic [15:0] k_out[31:0];             // Les 32 clés générées par key_expansion

    // Instanciation du module key_expansion
    key_expansion key_exp_inst (
        .wait_data(wait_data),
        .clk(clk),
        .rst(rst),
        .k_in(k_in),
        .key_ready(key_ready),
        .k_out(k_out)
    );

    // Instanciation du module encrypt_decrypt
    encrypt_decrypt encrypt_decrypt_inst (
        .wait_data(wait_data),
        .done(done),
        .clk(clk),
        .rst(rst),
        .key_ready(key_ready),
        .cryp_decryp(cryp_decryp),
        .data_in(data_in),
        .key(k_out),
        .sel(sel),
        .crypt_out(crypt_out)
    );
    
    //multiplexeur
    
     mux_data_in mux_data_in_inst(
        .text_in(text_in),
        .sel(sel),
        .cryp_decryp(cryp_decryp),
        .crypt_out(crypt_out),
        .data_in(data_in)
    );

endmodule



