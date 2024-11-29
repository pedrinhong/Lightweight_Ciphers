`timescale 1ns / 1ps


module register_file_32x32_sync (
    input logic clk,                           // Horloge
    input logic rst,                           // Réinitialisation asynchrone
    input logic write_en,                      // Signal d'activation pour l'écriture
    input logic [4:0] addr,                    // Adresse commune pour l'écriture et la lecture
    input logic [31:0] write_data,             // Données à écrire
    output logic [31:0] read_data              // Données lues
);

    // Déclaration des registres
    logic [31:0] registers [31:0]; // Tableau de 32 registres de 32 bits
    logic [31:0] read_reg;         // Registre temporaire pour stocker les données lues

    // Assignation de la sortie de lecture
    assign read_data = read_reg;

    // Bloc d'écriture et de lecture synchrones déclenché par l'horloge et la réinitialisation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Réinitialisation de tous les registres à zéro
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
            read_reg <= 32'b0; // Réinitialisation de la valeur lue
        end else begin
            // Lecture synchrone du registre spécifié par `addr`
            read_reg <= registers[addr];

            // Écriture si `write_en` est actif
            if (write_en) begin
                registers[addr] <= write_data;
            end
        end
    end

endmodule

