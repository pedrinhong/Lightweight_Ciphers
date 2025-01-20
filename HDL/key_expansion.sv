`timescale 1ns / 1ps

module key_expansion(
    input  logic wait_data,
    input  logic clk,                // Horloge
    input  logic rst,                // Réinitialisation asynchrone
    input  logic [15:0] k_in[3:0],   // Les 4 clés initiales en entrée (16 bits chacune)
    output logic key_ready[31:0],
    output logic [15:0] k_out[31:0]  // Tableau de 32 clés en sortie (16 bits chacune)
);

// Constante z0 (62 bits)
// static u8 z0[62] = {1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0,1,1,1,1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0};
logic [61:0] z0 = 62'b01100111000011010100100010111110110011100001101010010001011111;
    // Variables internes
    integer i;               // Index de génération
    logic [15:0] tmp;        // Valeur temporaire
    logic [15:0] tm1;        // Résultat intermédiaire 1
    logic [15:0] tm2;        // Résultat intermédiaire 2
    logic [4:0]  r_round;
    logic        w_z;
    
    always_comb begin
        tmp  = {k_out[r_round - 'h1][2:0], k_out[r_round - 'h1][15:3]}; // Rotation à droite de 3 bits
        tm1  = tmp ^ k_out[r_round - 'h3];
        tm2  = tm1 ^ {tm1[0], tm1[15:1]}; 
        w_z = z0[r_round-'h4];
    end

    // Processus synchronisé à l'horloge pour générer les clés
    always_ff @(posedge clk) begin
        if (rst || wait_data) begin
            // Copie des clés initiales
            for (i = 0; i < 4; i++) begin
                k_out[i] <= k_in[i];
                key_ready[i] <= 1;
            end

            // Réinitialisation des clés
            for (i = 4; i < 32; i++) begin
                k_out[i] <= 16'h0000;
                key_ready[i] <= 0;
            end
            r_round <= 'h4;

        end else begin
                if (r_round == 31) begin
                    r_round <= 'h4;
                end
                else begin
                    r_round <= r_round + 'h1;
                end
                key_ready[r_round] <= 1;
                k_out[r_round] <= (~k_out[r_round - 'h4]) ^ tm2 ^ w_z ^ 16'h0003;
//            // Génération des clés (indices 4 à 31)
//            for (i = 4; i < 32; i++) begin
//                tmp  = {k_out[i-1][2:0], k_out[i-1][15:3]}; // Rotation à droite de 3 bits
//                tm1  = tmp ^ k_out[i-3];
//                tm2  = tm1 ^ {tm1[0], tm1[15:1]};           // Rotation à droite de 1 bit
//                k_out[i] <= (~k_out[i-4]) ^ tm2 ^ z0[i-4] ^ 16'h0003;
//            end
            
        end
    end

endmodule
