`timescale 1ns / 1ps

module tb_fsm_simon;

    // Paramètres d'horloge
    logic clk;
    logic resetn;
    
    // Signaux de la FSM
    logic [7:0] fsm_data_in;
    logic fsm_control_in;
    logic result_ready;
    logic fsm_control_out;
    logic [7:0] fsm_data_out;
    logic cryp_decryp;
    logic [7:0] k_in_fsm [7:0];
    logic [7:0] text_in_fsm [3:0];
    logic [7:0] crypt_out_fsm [3:0];

    // Signaux combinés pour SIMON
    logic [15:0] k_in [3:0];
    logic [15:0] text_in [1:0];
    logic [15:0] crypt_out [1:0];

    // LEDs de la FSM
    logic led_input_commande;
    logic led_key_input;
    logic led_text_input;
    logic led_wait_result;
    logic led_output_result;
    
    // Signaux de l'UART
    logic        data_tx;             //  Serial transmitter's data out.
    logic        active_flag;         //  high when Tx is transmitting, low when idle.
    logic        done_flag;            //  high when transmission is done, low when active.

    // Combinaison des données pour SIMON
    always_comb begin
        // Recombinaison des clés (k_in) à partir des k_in_fsm
        k_in[0] = {k_in_fsm[1], k_in_fsm[0]};  // Clé 0
        k_in[1] = {k_in_fsm[3], k_in_fsm[2]};  // Clé 1
        k_in[2] = {k_in_fsm[5], k_in_fsm[4]};  // Clé 2
        k_in[3] = {k_in_fsm[7], k_in_fsm[6]};  // Clé 3
    
        // Recombinaison du texte d'entrée (text_in)
        text_in[0] = {text_in_fsm[1], text_in_fsm[0]};
        text_in[1] = {text_in_fsm[3], text_in_fsm[2]};

        // Pré-remplissage des valeurs de crypt_out_fsm
        crypt_out_fsm[0] = crypt_out[0][7:0];
        crypt_out_fsm[1] = crypt_out[0][15:8];
        crypt_out_fsm[2] = crypt_out[1][7:0];
        crypt_out_fsm[3] = crypt_out[1][15:8];
    end

    // Horloge
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Période de 10 unités de temps
    end

    // Réinitialisation
    initial begin
        resetn = 0;
        #15 resetn = 1;  // Sortie de reset après 15 unités de temps
    end

    
    // Instance de la FSM (gestion des états de l'algorithme)
    fsm u_fsm (
        .uart_tx_active(uart_tx_active),
        .uart_tx_done(uart_tx_done),
        .clk(clk),
        .reset(~resetn),
        .data_in(fsm_data_in),             // Données reçues depuis l'UART
        .control_in(fsm_control_in),       // Signal de contrôle de réception UART
        .result_ready(result_ready),       // Signal de résultat prêt
        .control_out(fsm_control_out),     // Signal de contrôle pour l'UART
        .data_out(fsm_data_out),           // Données transmises vers UART
        .cryp_decryp(cryp_decryp),         // Signal pour SIMON (chiffrement/déchiffrement)
        .k_in(k_in_fsm),                       // Clés d'entrée pour SIMON
        .text_in(text_in_fsm),                 // Texte d'entrée pour SIMON
        .crypt_out(crypt_out_fsm),             // Résultat du chiffrement/déchiffrement
        //.wait_data(wait_data),
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
    

    // Stimulus : séquence de test
    initial begin
        // Initialisation des variables
        fsm_control_in = 0;
        fsm_data_in = 0;

        @(posedge resetn);  // Attente de la sortie de reset

           // === INPUT_COMMANDE ===
    $display("=== INPUT_COMMANDE ===");
    //fsm_data_in = 8'b0000_0000;  // Commande pour SIMON
    fsm_data_in = 8'b0000_0001;  // Commande pour SIMON
    fsm_control_in = 1; 
    
    //clk = 1;
    #10;
    
    //clk = 0;
    fsm_control_in = 0;
    #10;

    // === KEY_INPUT ===
    $display("=== KEY_INPUT ===");
    // Envoyer les 8 clés (4 clés de 16 bits, MSB puis LSB)

    // k[0] = 0x0100
    
    fsm_data_in = 8'h00; 
    //clk = 1;
    fsm_control_in = 1; 
    #10;  // MSB
    fsm_control_in = 0; 
    //clk = 0;
    #10;  // MSB
    fsm_data_in = 8'h01; 
    fsm_control_in = 1; 
    //clk = 1;
    #10;  // MSB
    fsm_control_in = 0; 
    //clk = 0;
    #10;  // LSB

    // k[1] = 0x0908
        fsm_data_in = 8'h08; 
      //  clk = 1; 
        fsm_control_in = 1; 
        #10;  // MSB
        fsm_control_in = 0; 
      //  clk = 0; 
        #10;  // MSB
        fsm_data_in = 8'h09; 
        fsm_control_in = 1; 
        //clk = 1;
        #10;  // LSB
        fsm_control_in = 0; 
        //clk = 0;
        #10;  // LSB

        // k[2] = 0x1110
        fsm_data_in = 8'h10; 
        //clk = 1; 
        fsm_control_in = 1; 
        #10;  // MSB
        fsm_control_in = 0; 
      //  clk = 0; 
        #10;  // MSB
        fsm_data_in = 8'h11; 
        fsm_control_in = 1; 
      //  clk = 1;
        #10;  // LSB
        fsm_control_in = 0; 
      //  clk = 0;
        #10;  // LSB

        // k[3] = 0x1918
        fsm_data_in = 8'h18; 
      //  clk = 1; 
        fsm_control_in = 1; 
        #10;  // MSB
        fsm_control_in = 0; 
      //  clk = 0; 
        #10;  // MSB
        fsm_data_in = 8'h19; 
        fsm_control_in = 1; 
      //  clk = 1;
        #10;  // LSB
        fsm_control_in = 0; 
       // clk = 0;
        #10;  // LSB

        // === TEXT_INPUT ===
        $display("=== TEXT_INPUT ===");

        // Envoyer text[0] = 0x6565
        fsm_data_in = 8'h65; 
        //clk = 1; 
        fsm_control_in = 1; 
        #10;  // MSB
        fsm_control_in = 0; 
        //clk = 0; 
        #10;  // MSB
        fsm_data_in = 8'h65; 
        fsm_control_in = 1; 
        //clk = 1;
        #10;  // LSB
        fsm_control_in = 0; 
        //clk = 0;
        #10;  // LSB

        // Envoyer text[1] = 0x6877
        fsm_data_in = 8'h77; 
        //clk = 1; 
        fsm_control_in = 1; 
        #10;  // MSB
        fsm_control_in = 0; 
        //clk = 0; 
        #10;  // MSB
        fsm_data_in = 8'h68; 
        fsm_control_in = 1; 
        //clk = 1;
        #10;  // LSB
        fsm_control_in = 0; 
        //clk = 0;
        #10;  // LSB

/*
    // k[1] = 0x0908
    fsm_data_in = 8'h08; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // MSB
    fsm_data_in = 8'h09; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // LSB

    // k[2] = 0x1110
    fsm_data_in = 8'h10; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // MSB
    fsm_data_in = 8'h11; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // LSB

    // k[3] = 0x1918
    fsm_data_in = 8'h18; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // MSB
    fsm_data_in = 8'h19; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // LSB

    // === TEXT_INPUT ===
    $display("=== TEXT_INPUT ===");
    // Envoyer text[0] = 0x6565
    fsm_data_in = 8'h65; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // MSB
    fsm_data_in = 8'h65; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // LSB

    // Envoyer text[1] = 0x6877
    fsm_data_in = 8'h77; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // MSB
    fsm_data_in = 8'h68; fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;  // LSB

*/
        // === WAIT_RESULT ===
        $display("=== WAIT_RESULT ===");
        #50;
        
        // === OUTPUT_RESULT ===
        $display("=== OUTPUT_RESULT ===");
        repeat (4) begin
            @(posedge clk);
            $display("Output Data: %h", fsm_data_out);
        end

        $display("=== TEST TERMINÉ ===");
        $stop;
    end

    // Surveillance des signaux
    always @(posedge clk) begin
        $display("Time: %0t | Control_in: %b | Result_ready: %b | Data_out: %h",
                 $time, fsm_control_in, result_ready, fsm_data_out);
    end

endmodule
