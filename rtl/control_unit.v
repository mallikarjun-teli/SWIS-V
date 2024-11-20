`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"
`include "maindec.v"
`include "aludec.v"

module control_unit(
input wire [31:0] i_Instr,
output wire o_RegSrc,
output wire o_Sel1,
output wire o_Sel2,
output wire [3:0] o_AluCtrl,
output wire o_Load,
output wire o_Branch,
output wire o_Jal,
output wire o_Jalr,
output wire o_MemSrc,
output wire [1:0] o_ResultSrc
);


maindec md(
	.i_opcode(i_Instr[6:0]),
	.o_rf_wr(o_RegSrc),
	.o_selop1(o_Sel1),
	.o_selop2(o_Sel2),
	.o_branch(o_Branch),
	.o_load(o_Load),
	.o_jal(o_Jal),
	.o_jalr(o_Jalr),
	.o_wr_en(o_MemSrc),
	.o_resultsrc(o_ResultSrc)
);

aludec ad(
	.i_instr(i_Instr),
	.o_alu_ctrl(o_AluCtrl)
);

endmodule