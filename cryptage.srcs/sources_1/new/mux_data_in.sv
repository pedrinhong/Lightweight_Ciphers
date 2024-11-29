module mux_data_in (
    input  logic [15:0] text_in [1:0],   
    input  logic  sel,
    input  logic cryp_decryp,            
    input  logic [15:0] crypt_out [1:0], 
    output logic [15:0] data_in [1:0]    
);

    always_comb begin
        if (sel == 0) begin
            /*if (cryp_decryp == 0) begin
                data_in[0] = text_in[0];
                data_in[1] = text_in[1];
            end */
            //else begin
                data_in[0] = text_in[1];
                data_in[1] = text_in[0];
            //end   
        end
        else begin
            if (cryp_decryp == 0) begin
                data_in[0] = crypt_out[0];
                data_in[1] = crypt_out[1];
            end 
            else begin
                data_in[0] = crypt_out[0];
                data_in[1] = crypt_out[1];
            end 
        end
    end

endmodule
