`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"
`include "alu.v"
`include "branch_decision.v"

module EX(
input wire clk,
input wire rst_n,
input wire [31:0] i_rs1_data,
input wire [31:0] i_rs2_data,
input wire [31:0] i_imm_data,
input wire [31:0] i_pc,
input wire [3:0] i_alu_ctrl,
input wire [2:0] i_func3,
input wire [6:0] i_opcode,
input wire i_branch,
input wire i_jal,
input wire i_jalr,
input wire i_selop1,
input wire i_selop2,
input wire i_wr_en,
input wire [1:0] i_resultsrc,
input wire i_RegSrc,
// outputs to the next stage(MEM)
output wire [31:0] o_result, // must be forwarded to both IF and MEM stages
output wire [31:0] o_data_store,
output wire [31:0] o_pc,
output wire [2:0] o_func3,
output wire [6:0] o_opcode,
output wire [1:0] o_wr_en,
// outputs for the IF stage
output wire o_boj,
output wire o_jal,
output wire o_jalr,
output wire [31:0] o_imm_data,
output wire o_resultsrc,
output wire o_RegSrc
);

wire [31:0] is_op1, is_op2;
wire is_branch;

// signals going to IF stage
assign o_boj = (is_branch & i_branch)  | i_jal;
assign o_jalr = i_jalr;
assign o_jal = i_jal;
assign o_imm_data = i_imm_data;
assign o_wr_en = i_wr_en;
assign o_resultsrc = i_resultsrc;
assign o_RegSrc = i_RegSrc;

// MUX before the ALU
assign is_op1 = i_selop1 ? i_pc : i_rs1_data;
assign is_op2 = i_selop1 ? i_rs2_data : i_imm_data; 

// Data to store into Data Memory
assign o_data_store = i_rs2_data;

assign o_func3 = i_func3;   
assign o_opcode = i_opcode;
assign o_pc = i_pc;

branch_decision branch_dec_inst (
	.i_result(o_result),
	.i_func3(i_func3),
	.o_branch(is_branch)
);

alu alu_inst (
	.i_op1(is_op1),
	.i_op2(is_op2),
	.i_alu_ctrl(i_alu_ctrl),
	.o_result(o_result)
);

endmodule
