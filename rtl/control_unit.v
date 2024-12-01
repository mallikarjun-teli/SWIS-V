`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"
`include "../rtl/maindec.v"
`include "../rtl/aludec.v"

module control_unit(
	input wire clk,
	input wire rst_n,
	input wire [31:0] i_Instr,
	output wire o_RegSrcE,
	output wire o_Sel1E,
	output wire o_Sel2E,
	output wire [3:0] o_alu_ctrl,
	output wire o_LoadE,
	output wire o_BranchE,
	output wire o_JalE,
	output wire o_JalrE,
	output wire o_MemSrcE,
	output wire [1:0] o_ResultSrcE
);


maindec md(
	.clk(clk),
    .rst_n(rst_n),
    .i_opcode(i_Instr [6:0]),
    .o_RegSrcE(o_RegSrcE),
    .o_Sel1E(o_Sel1E),
    .o_Sel2E(o_Sel2E),
    .o_LoadE(o_LoadE),
    .o_BranchE(o_BranchE),
    .o_JalE(o_JalE),
    .o_JalrE(o_JalrE),
    .o_MemSrcE(o_MemSrcE),
    .o_ResultSrcE(o_ResultSrcE)
);

aludec ad(
	.i_instr(i_Instr),
	.o_alu_ctrl(o_alu_ctrl)
);

endmodule