module encrypt_decrypt(
    output logic done,
    input logic  wait_data,
    input  logic clk,                        // Horloge
    input  logic rst,                        // Réinitialisation asynchrone
    input  logic key_ready[31:0],
    input  logic cryp_decryp,                  
    input  logic [15:0] data_in[1:0],        // Texte clair (2 blocs de 16 bits)
    input  logic [15:0] key[31:0],           // Tableau de 32 clés
    output logic sel,
    output logic [15:0] crypt_out[1:0]       // Texte chiffré (2 blocs de 16 bits)
);

    // Variables internes
    logic [15:0] crypt[1:0];                 // Texte intermédiaire
    logic [5:0] round;                       // Index pour la boucle


    always_comb begin
       //if (round <=31 ) begin
       crypt[0] <= data_in[1] ^ 
                           (({data_in[0][14:0], data_in[0][15]}) &     // ROTATE_LEFT_16(crypt[0], 1)
                           ({data_in[0][7:0], data_in[0][15:8]})) ^   // ROTATE_LEFT_16(crypt[0], 8)
                           ({data_in[0][13:0], data_in[0][15:14]}) ^   // ROTATE_LEFT_16(crypt[0], 2)
                            key[round];
       crypt[1] <= data_in[0];
       //end
       //else begin
            //crypt[0] <= data_in[0];
            //crypt[1] <= data_in[1];
       //end
       
       
    end
    
    always_comb begin
        if ((round == 0 && cryp_decryp == 0) || (round == 31 && cryp_decryp == 1)) begin
            sel = 0;
        end
        else begin
            sel = 1;
        end    
    end

      // Processus 
    always_ff @(posedge clk) begin
        if(rst || wait_data) begin
            //crypt_out[0] <= 16'h0000;
            //crypt_out[1] <= 16'h0000;
            if (cryp_decryp == 0) begin
                round = 0;
            end
            else begin
                round = 32;
            end
        end 
        else begin
            if(key_ready[round]) begin
              // Assignation des résultats
              crypt_out[0] <= crypt[0];
              crypt_out[1] <= crypt[1];
            end
            if (cryp_decryp == 0) begin
                if (round == 32) begin
                    done  <=1;
                    //round <=0;
                end
                else begin
                    round = round + 1;
                    done  <=0;
                end
            end
            else begin
                if (round == 0 ) begin
                    //round <= 32;
                    done  <=1;
                end
                else begin
                    round = round - 1;
                    done  <=0;
                end
            end
        end
    end
endmodule
