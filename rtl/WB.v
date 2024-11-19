`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module WB(
input wire clk,
input wire rst_n,
input wire [31:0] i_wb_data, 
input wire [6:0] i_opcode,
input wire [1:0] i_resultsrc,
input wire [31:0] i_pc_4,
input wire [31:0] i_result,
input wire i_RegSrc,
output wire o_rf_wr, // write enable for register file 
output wire [31:0] o_wb_data // data to be written to Register file
);

assign o_wb_data = (i_RegSrc & rst_n) ? 
                    ((i_resultsrc == 2'b00) ? i_result : 
                    (i_resultsrc == 2'b01) ?  i_wb_data : 
                    (i_resultsrc == 2'b10) ? i_pc_4 : 32'd0) : 32'd0;

endmodule
