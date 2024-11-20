`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"
`include "reg_file.v"
`include "imm_gen.v"
`include "control_unit.v"

module ID(
input wire clk,
input wire rst_n,
input wire [31:0] i_Instr, // Instruction Fetched in IF stage
input wire signed [31:0] i_write_data, // Data to be written to register file from the WB stage
input wire [31:0] i_Pc, // PC of the current instruction
input wire i_wr, // write enable signal from the WB stage, enables the register file to write to rd.

output wire [6:0] o_OpE, // opcode of the current instruction
output wire [2:0] o_Func3E, // func3 of the current instruction 
output wire [31:0] o_RS1E, // rs1 data from register file
output wire [31:0] o_RS2E, // rs2 data from register file
output wire [31:0] o_ImmE, // signa extended immediate value
output wire [31:0] o_PcE, // PC for the next stage

output wire o_RegSrc,
output wire o_Sel1E,
output wire o_Sel2E,
output wire [3:0] o_ALUCtrlE, // ALU Control signals
output wire o_LoadE,
output wire o_BranchE,
output wire o_JalE,
output wire o_JalrE, 
output wire o_MemSrcE,
output wire [1:0] o_ResultSrcE
);

wire [6:0] is_Opcode;
wire [2:0] is_Func3;
wire [4:0] is_Rs1, is_Rs2, is_Rd;
wire is_Re;

wire [31:0] o_rs1_data; // rs1 data from register file
wire [31:0] o_rs2_data; // rs2 data from register file
wire [31:0] o_imm_data; // signa extended immediate value

wire RegSrc;
wire o_Sel1;
wire o_Sel2;
wire [3:0] o_AluCtrl; // ALU Control signals
wire o_Branch;
wire o_Load;
wire o_Jal;
wire o_Jalr;
wire o_MemSrc;
wire [1:0] o_ResultSrc;

reg [31:0] Rs1_reg; // rs1 data from register file
reg [31:0] Rs2_reg; // rs2 data from register file
reg [31:0] Imm_reg; // signa extended immediate value
reg [6:0] Opcode_reg; // opcode of the current instruction
reg [2:0] Func3_reg; // func3 of the current instruction 
reg [31:0] PC_reg;// PC for the next stage
reg RegSrc_reg;
reg Sel1_reg;
reg Sel2_reg;
reg [3:0] ALUCtrl_reg; // ALU Control signals 
reg Load_reg;
reg Branch_reg;
reg Jal_reg;
reg Jalr_reg;
reg MemSrc_reg;
reg [1:0] Resultsrc_reg;


assign is_Re = ~((is_Opcode == `J) | (is_Opcode == `U) | (is_Opcode == `UPC)); // every instruction except LUI, AUIPC and JAL requires register file to be read
assign is_Rs1 = i_Instr[19:15];
assign is_Rs2 = i_Instr[24:20];
assign is_Rd = i_Instr[11:7];
assign is_Opcode = i_Instr[6:0];
assign is_Func3 = i_Instr[14:12];

reg_file reg_file_inst(
	.clk(clk),
	.rst_n(rst_n),
	.i_re(is_Re),
	.i_wr(i_wr),
	.i_rs1(is_Rs1),
	.i_rs2(is_Rs2),
	.i_rd(is_Rd),
	.i_write_data(i_write_data),
	.o_read_data1(o_rs1_data),
	.o_read_data2(o_rs2_data)
);

imm_gen imm_gen_inst (
  	.i_Instr(i_Instr),
  	.o_ImmData(o_imm_data)
);

control_unit control_unit_inst (
  	.i_Instr(i_Instr),
	.o_RegSrc(o_RegSrc),
	.o_Sel1(o_Sel1),
	.o_Sel2(o_Sel2),
	.o_AluCtrl(o_AluCtrl),
	.o_Load(o_Load),
	.o_Branch(o_Branch),
	.o_Jal(o_Jal),
	.o_Jalr(o_Jalr),
	.o_MemSrc(o_MemSrc),
	.o_ResultSrc(o_ResultSrc)
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
		RegSrc_reg <= 1'b0;	
		Load_reg <= 1'b0;
		Branch_reg <= 1'b0;
		Jal_reg <= 1'b0;		
		Jalr_reg <= 1'b0;
		Sel2_reg <= 1'b0;
		Sel2_reg <= 1'b0;
		MemSrc_reg <= 1'b0;
		Resultsrc_reg <= 2'bxx;			
	end
	else
	begin  
        Opcode_reg <= is_Opcode; 
        Func3_reg <= is_Func3; 
		PC_reg <= i_Pc;
        Imm_reg <= o_imm_data;
		Rs1_reg <= o_rs1_data;
        Rs2_reg <= o_rs2_data;

		RegSrc_reg <= RegSrc;	
		Sel2_reg <= o_Sel1;	
		Sel2_reg <= o_Sel2;
        ALUCtrl_reg <= o_AluCtrl; 
		Load_reg <= o_Load;	
		Branch_reg <= o_Branch;
		Jal_reg <= o_Jal;
		Jalr_reg <= o_Jalr; 	
		MemSrc_reg <= o_MemSrc;	
		Resultsrc_reg <= o_ResultSrc;
	end
end

// register outputs  
assign o_OpE = Opcode_reg; 
assign o_Func3E = Func3_reg;
assign o_ImmE = Imm_reg;
assign o_RS1E = Rs1_reg; 
assign o_RS2E = Rs2_reg; 
assign o_PcE = PC_reg;

assign o_RegSrc = RegSrc_reg;
assign o_Sel1E = Sel2_reg;
assign o_Sel2E = Sel2_reg; 
assign o_ALUCtrlE = ALUCtrl_reg;
assign o_LoadE = Load_reg; 
assign o_BranchE = Branch_reg;
assign o_JalE = Jal_reg;
assign o_JalrE = Jalr_reg;	
assign o_MemSrcE = MemSrc_reg;
assign o_ResultSrcE = Resultsrc_reg;

endmodule
