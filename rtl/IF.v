`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module IF(
input wire clk,
input wire rst_n,

//instruction memory interface
input wire [31:0] i_inst,  //instruction code received from the instruction memory
input wire i_imem_ack,     //ack by instruction memory (active high)
output reg o_imem_stb,     //stub signal for instruction memroy
output reg [31:0] o_iaddr, //instruction address

//Change in PC
input wire [31:0] i_imm,
input wire [31:0] i_result,
input wire i_boj,
input wire i_jalr,

// register outputs
output wire [31:0] o_InstrD,
output wire [31:0] o_PcD
);

//internal signals and registers
wire [31:0] o_pc;
reg [31:0] o_instr; 
wire is_stall = !i_imem_ack & rst_n;
wire [31:0] is_pc_increment;
reg [31:0] flopr;
wire [31:0] pc;

//IF registers
reg [31:0] InstrF_reg;
reg [31:0] PCF_reg; 

assign is_pc_increment = is_stall ? 32'd0 : (i_boj ? i_imm : 32'd4 );
assign pc = i_jalr ? i_result &~1 : (flopr);
assign o_pc = pc;

always @(posedge clk)
begin
	if(~rst_n)
	begin
		flopr <= `PC_RESET;
	end
	else 
	begin
		flopr <= flopr + is_pc_increment;
	end

	if(~rst_n)
	begin
		InstrF_reg <= 32'b0;
		PCF_reg <= 32'b0;
		end
	else
		begin
		InstrF_reg <= o_instr;
		PCF_reg <= o_pc;
		end
end

always @(*)
begin
	if(~rst_n)
	begin
		o_iaddr = 32'd0;
		o_imem_stb = 1'b0;
		o_instr = `NOP;
	end
	else if(is_stall)
		o_instr = `NOP;
	else
	begin
		o_iaddr = pc;
		o_imem_stb = 1'b1;
		o_instr = i_inst;
	end
end

assign o_InstrD = ~rst_n ? 32'b0 : InstrF_reg;
assign o_PcD = ~rst_n ? 32'b0 : PCF_reg;
endmodule
