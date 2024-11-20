`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module IF(
input wire clk,
input wire rst_n,

input wire [31:0] i_Inst,  
input wire i_Imem_ack,     
output reg o_Imem_stb,     
output reg [31:0] o_Iaddr, 

input wire [31:0] i_Imm,
input wire [31:0] i_Result,
input wire i_Boj,
input wire i_Jalr,

output wire [31:0] o_InstrD,
output wire [31:0] o_PcD
);

//internal signals and registers

wire [31:0] o_Pc;
wire is_stall = !i_Imem_ack & rst_n;
wire [31:0] is_Pc_increment;
reg [31:0] Pc;
reg [31:0] o_Instr;

//IF registers
reg [31:0] Instr_reg;
reg [31:0] Pc_reg; 

assign is_Pc_increment = i_Boj ? i_Imm : ( is_stall ? 32'd0 : 32'd4 );
assign o_Pc = Pc;

always @(posedge clk)
begin
	if(~rst_n)
	begin
		Pc <= `PC_RESET;
	end
	else if(is_stall)
	begin
		Pc <= Pc;
	end
	else if(i_Jalr)
	begin
		Pc <= i_Result &~1;	
	end
	else
	begin
		Pc <= Pc + is_Pc_increment;
	end

	if(~rst_n)
	begin
		Instr_reg <= 32'b0;
		Pc_reg <= 32'b0;
		end
	else
		begin
		Instr_reg <= o_Instr;
		Pc_reg <= o_Pc;
		end
end

always @(*)
begin
	if(~rst_n)
	begin
		o_Iaddr = 32'd0;
		o_Imem_stb = 1'b0;
		o_Instr = `NOP;
	end
	else if(is_stall)
		o_Instr = `NOP;
	else
	begin
		o_Iaddr = Pc;
		o_Imem_stb = 1'b1;
		o_Instr = i_Inst;
	end
end

assign o_InstrD = ~rst_n ? 32'b0 : Instr_reg;
assign o_PcD = ~rst_n ? 32'b0 : Pc_reg;
endmodule
