`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"
`include "reg_file.v"
`include "imm_gen.v"
`include "control_unit.v"

module ID(
input wire clk,
input wire rst_n,
input wire [31:0] i_instr, // Instruction Fetched in IF stage
input wire signed [31:0] i_write_data, // Data to be written to register file from the WB stage
input wire [31:0] i_pc, // PC of the current instruction
input wire i_wr, // write enable signal from the WB stage, enables the register file to write to rd.
output wire [31:0] o_RS1E, // rs1 data from register file
output wire [31:0] o_RS2E, // rs2 data from register file
output wire [31:0] o_ImmE, // signa extended immediate value
output wire [6:0] o_OpE, // opcode of the current instruction
output wire [2:0] o_Func3E, // func3 of the current instruction
output wire [3:0] o_ALUCtrlE, // ALU Control signals  
output wire [31:0] o_PcE, // PC for the next stage
output wire o_BranchE,
output wire o_JalE,
output wire o_JalrE,
output wire o_Selop1E,
output wire o_Selop2E,
output wire o_WrenE,
output wire [1:0] o_ResultsrcE,
output wire o_RegSrc
);

wire [4:0] is_rs1, is_rs2, is_rd;
wire [6:0] is_opcode;
wire [2:0] is_func3;
wire is_re;

wire [31:0] o_rs1_data; // rs1 data from register file
wire [31:0] o_rs2_data; // rs2 data from register file
wire [31:0] o_imm_data; // signa extended immediate value
wire [6:0] o_opcode; // opcode of the current instruction
wire [2:0] o_func3; // func3 of the current instruction
wire [3:0] o_alu_ctrl; // ALU Control signals  
wire [31:0] o_pc; // PC for the next stage
wire o_branch;
wire o_jal;
wire o_jalr;
wire o_selop1;
wire o_selop2;
wire o_wr_en;
wire [1:0] o_resultsrc;
wire o_rf_wr;

reg [31:0] Rs1_reg; // rs1 data from register file
reg [31:0] Rs2_reg; // rs2 data from register file
reg [31:0] Imm_reg; // signa extended immediate value
reg [6:0] Opcode_reg; // opcode of the current instruction
reg [2:0] Func3_reg; // func3 of the current instruction
reg [3:0] ALUCtrl_reg; // ALU Control signals  
reg [31:0] PC_reg;// PC for the next stage
reg Branch_reg;
reg Jal_reg;
reg Jalr_reg;
reg Selop2_reg;
reg Selop1_reg;
reg Wren_reg;
reg [1:0] Resultsrc_reg;
reg RegSrc_reg;

assign is_rs1 = i_instr[19:15];
assign is_rs2 = i_instr[24:20];
assign is_rd = i_instr[11:7];
assign is_opcode = i_instr[6:0];
assign is_func3 = i_instr[14:12];

assign o_func3 = is_func3;
assign o_opcode = is_opcode;

assign is_re = ~((is_opcode == `J) | (is_opcode == `U) | (is_opcode == `UPC)); // every instruction except LUI, AUIPC and JAL requires register file to be read

assign o_pc = i_pc;

reg_file reg_file_inst(
	.clk(clk),
	.rst_n(rst_n),
	.i_re(is_re),
	.i_wr(i_wr),
	.i_rs1(is_rs1),
	.i_rs2(is_rs2),
	.i_rd(is_rd),
	.i_write_data(i_write_data),
	.o_read_data1(o_rs1_data),
	.o_read_data2(o_rs2_data)
);

imm_gen imm_gen_inst (
  	.i_instr(i_instr),
  	.o_imm_data(o_imm_data)
);

control_unit control_unit_inst (
  	.i_instr(i_instr),
  	.o_alu_ctrl(o_alu_ctrl),
	.o_branch(o_branch),
	.o_jal(o_jal),
	.o_jalr(o_jalr),
	.o_selop1(o_selop1),	
	.o_selop2(o_selop2),
	.o_wr_en(o_wr_en),
	.o_resultsrc(o_resultsrc),
	.o_rf_wr(o_rf_wr)
);

always@(posedge clk)
begin
	if(~rst_n)
	begin
		Rs1_reg <= 32'b0;
        Rs2_reg <= 32'b0;
        Imm_reg <= 32'b0;
        Opcode_reg <= 7'b0;
        Func3_reg <= 3'b0;
        ALUCtrl_reg <= 4'b0; 
        PC_reg <= 32'b0;
		Branch_reg <= 1'b0;
		Jal_reg <= 1'b0;		
		Jalr_reg <= 1'b0;
		Selop1_reg <= 1'b0;
		Selop2_reg <= 1'b0;
		Wren_reg <= 1'b0;
		Resultsrc_reg <= 2'bxx;
		RegSrc_reg <= 1'b0;		
	end
	else
	begin
		Rs1_reg <= o_rs1_data;
        Rs2_reg <= o_rs2_data; 
        Imm_reg <= o_imm_data;  
        Opcode_reg <= o_opcode; 
        Func3_reg <= o_func3;
        ALUCtrl_reg <= o_alu_ctrl; 
        PC_reg <= o_pc; 
		Branch_reg <= o_branch;
		Jal_reg <= o_jal;
		Jalr_reg <= o_jalr;	
		Selop1_reg <= o_selop1;	
		Selop2_reg <= o_selop2;	
		Wren_reg <= o_wr_en;	
		Resultsrc_reg <= o_resultsrc;
		RegSrc_reg <= o_rf_wr;
	end
end

// register outputs
assign o_RS1E = Rs1_reg; 
assign o_RS2E = Rs2_reg; 
assign o_ImmE = Imm_reg; 
assign o_OpE = Opcode_reg; 
assign o_Func3E = Func3_reg; 
assign o_ALUCtrlE = ALUCtrl_reg;  
assign o_PcE = PC_reg;
assign o_BranchE = Branch_reg;
assign o_JalE = Jal_reg;
assign o_JalrE = Jalr_reg;
assign o_Selop1E = Selop1_reg;
assign o_Selop2E = Selop2_reg;	
assign o_WrenE = Wren_reg;
assign o_ResultsrcE = Resultsrc_reg;
assign o_RegSrc = RegSrc_reg;

endmodule
