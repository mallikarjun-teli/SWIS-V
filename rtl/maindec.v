`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module maindec(
input wire [6:0] i_opcode,
output wire o_rf_wr,
output wire o_selop1,
output wire o_selop2,
output wire o_branch,
output wire o_load,
output wire o_jal,
output wire o_jalr,
output wire o_wr_en,
output wire [1:0] o_resultsrc
);

assign o_rf_wr = ((i_opcode == `B) | (i_opcode == `S)) ? 1'b0 : 1'b1;
assign o_selop1 = (i_opcode == `UPC | i_opcode == `JR) ? 1 :0;
assign o_selop2 = (i_opcode == `R | i_opcode == `B) ? 1 :0;
assign o_load = (i_opcode == `LD) ? 1'b1 : 1'b0;
assign o_branch = (i_opcode == `B) ? 1 :0;
assign o_jal = (i_opcode == `J) ? 1 :0;
assign o_jalr = (i_opcode == `JR) ? 1 :0;
assign o_wr_en = (i_opcode == `S) ? 1 :0;
assign o_resultsrc = ((i_opcode == `J) | (i_opcode == `JR)) ? 2'b10 : ((i_opcode == `LD) ? 2'b01 : 2'b00);


endmodule
