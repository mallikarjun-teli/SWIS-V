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
input wire [31:0] i_Pc,
input wire [3:0] i_AluCtrl,
input wire [2:0] i_Func3,
input wire i_RegSrc,
input wire [31:0] i_Imm,
input wire i_Sel1,
input wire i_Sel2,
input wire i_Load,
input wire i_Branch,
input wire i_Jal,
input wire i_Jalr,
input wire i_MemSrc,
input wire [1:0] i_ResultSrc,

output wire [31:0] o_DataStoreW,
output wire [31:0] o_ResultW,
output wire [2:0] o_Func3W,
output wire o_RegSrcW,
output wire o_MemSrcW,
output wire [1:0] o_ResultSrcW,
output wire [31:0] o_PcW,
output wire o_Load,

output wire o_Boj,
output wire o_Jalr,
output wire [31:0] o_Imm_data
);

wire [31:0] is_op1, is_op2;
wire is_branch_pred;
wire [31:0] o_Result;

reg [31:0] DataStore_reg;
reg [31:0] Result_reg;
reg [6:0] Opcode_reg;
reg [2:0] Func3_reg;
reg RegSrc_reg;
reg MemSrc_reg;
reg [1:0] ResultSrc_reg;
reg [31:0] Pc_reg;
reg Load_reg;

// signals going to IF stage
assign o_Boj = (is_branch_pred & i_Branch)  | i_Jal;
assign o_Jalr = i_Jalr;
assign o_Imm_data = i_Imm;

// MUX before the ALU
assign is_op1 = i_Sel1 ? i_Pc : i_rs1_data;
assign is_op2 = i_Sel1 ? i_rs2_data : i_Imm; 

branch_decision branch_dec_inst (
	.i_Result(o_Result),
	.i_Func3(i_Func3),
	.o_Branch(is_branch_pred)
);

alu alu_inst (
	.i_op1(is_op1),
	.i_op2(is_op2),
	.i_AluCtrl(i_AluCtrl),
	.o_Result(o_Result)
);

always @(posedge clk)
begin
	if(rst_n)
	begin
		DataStore_reg <= 32'b0;
		Result_reg <= 32'b0;
		Func3_reg <= 3'b0;
		RegSrc_reg <= 1'b0;
		MemSrc_reg <= 2'b0;
		ResultSrc_reg <= 1'b0;
		Pc_reg <= 32'b0;
		Load_reg <= 1'b0;
	end
	else
	begin
		Result_reg <= o_Result;
		DataStore_reg <= i_rs2_data;
		Func3_reg <= i_Func3;
		RegSrc_reg <= i_RegSrc;
		MemSrc_reg <= i_MemSrc;
		ResultSrc_reg <= i_ResultSrc;
		Pc_reg <= i_Pc;
		Load_reg <= i_Load;
	end
end 

assign o_ResultW = Result_reg;
assign o_DataStoreW = DataStore_reg; 
assign o_Func3W = Func3_reg; 
assign o_RegSrcW = RegSrc_reg;
assign o_MemSrcW = MemSrc_reg; 
assign o_ResultSrcW = ResultSrc_reg; 
assign o_PcW = Pc_reg; 
assign o_Load = Load_reg;


endmodule
