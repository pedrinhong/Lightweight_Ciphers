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

    // Instance de la FSM
    fsm u_fsm (
        .clk(clk),
        .reset(~resetn),
        .data_in(fsm_data_in),
        .control_in(fsm_control_in),
        .result_ready(result_ready),
        .control_out(fsm_control_out),
        .data_out(fsm_data_out),
        .cryp_decryp(cryp_decryp),
        .k_in(k_in_fsm),
        .text_in(text_in_fsm),
        .crypt_out(crypt_out_fsm),
        .led_input_commande(led_input_commande),
        .led_key_input(led_key_input),
        .led_text_input(led_text_input),
        .led_wait_result(led_wait_result),
        .led_output_result(led_output_result)
    );

    // Instance du module SIMON
    simon u_simon (
        .clk(clk),
        .rst(~resetn),
        .done(result_ready),
        .cryp_decryp(cryp_decryp),
        .k_in(k_in),
        .text_in(text_in),
        .crypt_out(crypt_out)
    );

    // Stimulus : séquence de test
    initial begin
        // Initialisation des variables
        fsm_control_in = 0;
        fsm_data_in = 0;
        result_ready = 0;

        @(posedge resetn);  // Attente de la sortie de reset

        // === INPUT_COMMANDE ===
        $display("=== INPUT_COMMANDE ===");
        fsm_data_in = 8'b0000_0001;  // Commande pour SIMON
        fsm_control_in = 1;
        @(posedge clk);
        fsm_control_in = 0;
        #10;

        // === KEY_INPUT ===
        $display("=== KEY_INPUT ===");
        for (int i = 0; i < 8; i++) begin
            fsm_data_in = 8'h10 + i;  // Clés d'exemple
            fsm_control_in = 1;
            @(posedge clk);
            fsm_control_in = 0;
            #10;
        end

        // === TEXT_INPUT ===
        $display("=== TEXT_INPUT ===");
        for (int i = 0; i < 4; i++) begin
            fsm_data_in = 8'h65 + i;  // Text d'exemple
            fsm_control_in = 1;
            @(posedge clk);
            fsm_control_in = 0;
            #10;
        end

        // === WAIT_RESULT ===
        $display("=== WAIT_RESULT ===");
        #50;
        result_ready = 1;  // SIMON indique que le résultat est prêt
        @(posedge clk);
        result_ready = 0;

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


/*`timescale 1ns / 1ps

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
    
    logic [15:0] k_in [3:0];
    logic [15:0] text_in_ [1:0];
    logic [15:0] crypt_out [1:0];

    // LEDs de la FSM
    logic led_input_commande;
    logic led_key_input;
    logic led_text_input;
    logic led_wait_result;
    logic led_output_result;


always_comb begin
        // Recombinaison des clés (k_in) à partir des k_in_fsm
        k_in[0] = {k_in_fsm[1], k_in_fsm[0]};  // Clé 0 : combine MSB et LSB
        k_in[1] = {k_in_fsm[3], k_in_fsm[2]};  // Clé 1
        k_in[2] = {k_in_fsm[5], k_in_fsm[4]};  // Clé 2
        k_in[3] = {k_in_fsm[7], k_in_fsm[6]};  // Clé 3
    
        // Recombinaison du texte d'entrée (text_in) à partir de text_in_fsm
        text_in[0] = {text_in_fsm[1], text_in_fsm[0]};  // Texte 0
        text_in[1] = {text_in_fsm[3], text_in_fsm[2]};  // Texte 1
    
        // Découpage des valeurs 16 bits de crypt_out en valeurs 8 bits dans crypt_out_fsm
        //crypt_out_fsm[0] = crypt_out[0][7:0];   // Bits de poids faibles (LSB) de crypt_out[0]
        //crypt_out_fsm[1] = crypt_out[0][15:8];  // Bits de poids forts (MSB) de crypt_out[0]
        //crypt_out_fsm[2] = crypt_out[1][7:0];   // Bits de poids faibles (LSB) de crypt_out[1]
        //crypt_out_fsm[3] = crypt_out[1][15:8];  // Bits de poids forts (MSB) de crypt_out[1]
        
        crypt_out_fsm[0] = 8'b00010000;  
        crypt_out_fsm[1] = 8'b01111001;  
       
        crypt_out_fsm[2] = 8'b01001101;  
        crypt_out_fsm[3] = 8'b00101010;  

    
    end



    // Horloge
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Période d'horloge de 10 unités de temps
    end

    // Réinitialisation
    initial begin
        resetn = 0;
        #15 resetn = 1;  // Sortie de reset après 15 unités de temps
    end

    // Instance de la FSM
    fsm u_fsm (
        .clk(clk),
        .reset(~resetn),
        .data_in(fsm_data_in),
        .control_in(fsm_control_in),
        .result_ready(result_ready),
        .control_out(fsm_control_out),
        .data_out(fsm_data_out),
        .cryp_decryp(cryp_decryp),
        .k_in(k_in_fsm),
        .text_in(text_in_fsm),
        .crypt_out(crypt_out_fsm),
        .led_input_commande(led_input_commande),
        .led_key_input(led_key_input),
        .led_text_input(led_text_input),
        .led_wait_result(led_wait_result),
        .led_output_result(led_output_result)
    );

    // Instance du module SIMON
    simon u_simon (
        .clk(clk),
        .rst(~resetn),
        .done(result_ready),
        .cryp_decryp(cryp_decryp),
        .k_in(k_in_),
        .text_in(text_in),
        .crypt_out(crypt_out)
    );

    // Stimulus : séquence de test
    initial begin
        // Initialisation des variables
        fsm_control_in = 0;
        fsm_data_in = 0;
        result_ready = 0;

        @(posedge resetn);  // Attendre la sortie de reset

        // === INPUT_COMMANDE ===
        $display("=== INPUT_COMMANDE ===");
        fsm_data_in = 8'b0000_0001;  // Commande pour SIMON
        fsm_control_in = 1;
        @(posedge clk);
        fsm_control_in = 0;
        #10;

        // === KEY_INPUT ===
        $display("=== KEY_INPUT ===");
        // Envoyer les 4 clés
        fsm_data_in = 8'h00;  // k[0] = 0x0100 (MSB)
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h01;  // k[0] (LSB)
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h08;  // k[1] = 0x0908
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h09;
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h10;  // k[2] = 0x1110
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h11;
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h18;  // k[3] = 0x1918
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h19;
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        // === TEXT_INPUT ===
        $display("=== TEXT_INPUT ===");
        // Envoyer text[0] = 0x6565
        fsm_data_in = 8'h65;  
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h65;  
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        // Envoyer text[1] = 0x6877
        fsm_data_in = 8'h77;
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        fsm_data_in = 8'h68;
        fsm_control_in = 1; @(posedge clk); fsm_control_in = 0; #10;

        // === WAIT_RESULT ===
        $display("=== WAIT_RESULT ===");
        #50;  // Attente fictive pour le résultat
        result_ready = 1;  // SIMON signal prêt
        @(posedge clk);
        result_ready = 0;

        // === OUTPUT_RESULT ===
        $display("=== OUTPUT_RESULT ===");
        repeat (2) begin
            @(posedge clk);
            $display("Output Data: %h", fsm_data_out);
        end

        $display("=== TEST TERMINÉ ===");
        $stop;  // Fin de la simulation
    end

    // Surveillance des états et des signaux
    always @(posedge clk) begin
        $display("Time: %0t | State: %b | fsm_control_in: %b | result_ready: %b | Data_out: %h",
                 $time, u_fsm.current_state, fsm_control_in, result_ready, fsm_data_out);
    end

endmodule*/
