`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module WB(
input wire clk,
input wire rst_n,
input wire i_RegSrc,
input wire [1:0] i_ResultRrc,
input wire [31:0] i_Result,
input wire [31:0] i_Wb_Data,
input wire [31:0] i_Pc_4,

output wire o_RegSrc, 
output wire [31:0] o_Wb_data 
);

assign o_RegSrc = i_RegSrc;
assign o_Wb_data = (i_RegSrc & rst_n) ? 
                    ((i_ResultRrc == 2'b00) ? i_Result : 
                    (i_ResultRrc == 2'b01) ?  i_Wb_Data : 
                    (i_ResultRrc == 2'b10) ? i_Pc_4 : 32'd0) : 32'd0;

endmodule
