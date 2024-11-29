`timescale 1ns / 1ps

module tb_simon;

    // Signaux pour le test
    logic clk;                             // Horloge
    logic rst;                             // Réinitialisation
    logic cryp_decryp;                     // Choix chiffrement/déchiffrement
    logic [15:0] k_in[3:0];                // Clés initiales
    logic [15:0] text_in[1:0];             // Texte en entrée
    logic [15:0] crypt_out[1:0];           // Résultat chiffré/déchiffré

    // Instanciation du module top_level
    simon uut (
        .clk(clk),
        .rst(rst),
        .cryp_decryp(cryp_decryp),
        .k_in(k_in),
        .text_in(text_in),
        .crypt_out(crypt_out)
    );

    // Génération de l'horloge
    always #5 clk = ~clk;  // Période de 10 ns

    // Séquence de test
    initial begin
        // Initialisation des signaux
        clk = 0;
        rst = 1;
        cryp_decryp = 0;
        k_in[0] = 16'h0100;
        k_in[1] = 16'h0908;
        k_in[2] = 16'h1110;
        k_in[3] = 16'h1918;
        text_in[0] = 16'h6565;
        text_in[1] = 16'h6877;

        // Étape 1 : Réinitialisation
        #10;
        rst = 0;

        // Étape 2 : Attendre la génération des clés
        #200;

        // Étape 3 : Tester le chiffrement
        cryp_decryp = 0;  // Mode chiffrement
        #1000;             // Attendre la fin du chiffrement

        // Affichage des résultats chiffrés
        $display("Chiffrement terminé : crypt_out[0] = %h, crypt_out[1] = %h", crypt_out[0], crypt_out[1]);

        // Étape 4 : Tester le déchiffrement
        text_in[0] = crypt_out[0];  // Utiliser les données chiffrées comme entrée
        text_in[1] = crypt_out[1];
        cryp_decryp = 0;            // Mode déchiffrement
        #1000;                       // Attendre la fin du déchiffrement

        // Affichage des résultats déchiffrés
        $display("Déchiffrement terminé : crypt_out[0] = %h, crypt_out[1] = %h", crypt_out[0], crypt_out[1]);

        // Fin de la simulation
        $stop;
    end

endmodule
