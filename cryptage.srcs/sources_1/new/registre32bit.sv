`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2024 11:07:02 AM
// Design Name: 
// Module Name: registre32bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module registre32bit (
    input logic clk,          // Horloge
    input logic rst,          // Réinitialisation asynchrone
    input logic en,           // Signal d'activation (enable)
    input logic [31:0] d,     // Entrée de données 32 bits
    output logic [31:0] q     // Sortie de données 32 bits
);

    // Bloc toujours déclenché par un front montant de l'horloge ou par une réinitialisation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 32'b0; // Réinitialisation du registre à zéro
        end else if (en) begin
            q <= d;     // Charger la valeur d'entrée dans le registre si 'en' est actif
        end
    end

endmodule




