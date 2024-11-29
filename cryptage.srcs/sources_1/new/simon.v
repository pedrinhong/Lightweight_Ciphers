`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2024 10:12:44 AM
// Design Name: 
// Module Name: simon
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


module simon (    input [3:0] i_a,
                  input [3:0] i_b,
                  input c_in,
                  output o_c_out,
                  output [3:0] sum);

reg [61:0] my_number = 62'b10101010101010101010101010101010101010101010101010101010101010;



   assign {o_c_out, sum} = i_a + i_b + c_in;
endmodule
