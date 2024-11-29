`timescale 1ns / 1ps

module tb_key_expansion;

    logic clk;
    logic rst;
    logic [15:0] k_in[3:0];
    logic [15:0] k_out[31:0];

    key_expansion uut (
        .clk(clk),
        .rst(rst),
        .k_in(k_in),
        .k_out(k_out)
    );

    // Génération d'horloge
    always #5 clk = ~clk;

    initial begin
        // Initialisation
        clk = 0;
        rst = 0;
        k_in[0] = 16'h0100;
        k_in[1] = 16'h0908;
        k_in[2] = 16'h1110;
        k_in[3] = 16'h1918;

        // Appliquer le reset
        #10 rst = 1;
        #10 rst = 0;

        // Attendre la génération complète
        #500;

        // Afficher les résultats
        $display("Clés générées :");
        for (int i = 0; i < 32; i++) begin
            $display("k_out[%0d] = %h", i, k_out[i]);
        end

        $stop;
    end
endmodule
