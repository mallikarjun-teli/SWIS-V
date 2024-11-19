`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module control_unit(
input wire [31:0] i_instr,
output reg [3:0] o_alu_ctrl,
output wire is_load_data,
output wire o_wb_data,
output wire o_branch,
output wire o_jal,
output wire o_jalr,
output wire o_selop1,
output wire o_selop2,
output wire o_wr_en,
output wire [1:0] o_resultsrc,
output wire o_rf_wr
);

wire [2:0] is_func3;
wire is_func7;
wire [6:0] is_opcode;

assign is_func7 = i_instr[30]; // only 30th bit is required to differentialte ADD,SUB,SRL,SRA,SRLI and SRLAI
assign is_func3 = i_instr[14:12];
assign is_opcode = i_instr[6:0];

assign o_branch = (is_opcode == `B) ? 1 :0;
assign o_jal = (is_opcode == `J) ? 1 :0;
assign o_jalr = (is_opcode == `JR) ? 1 :0;
assign o_selop1 = (is_opcode == `UPC | is_opcode == `JR) ? 1 :0;
assign o_selop2 = (is_opcode == `R | is_opcode == `B) ? 1 :0;
assign o_wr_en = (is_opcode == `S) ? 1 :0;
assign o_resultsrc = ((is_opcode == `J) | (is_opcode == `JR)) ? 2'b10 : ((is_opcode == `LD) ? 2'b01 : 2'b00);
assign o_rf_wr = ((is_opcode == `B) | (is_opcode == `S)) ? 1'b0 : 1'b1;

always @(*)
    begin
	if((is_opcode == `R)) begin
		if((is_func3 == `ADDI) & (is_func7 == 1'b0))
			o_alu_ctrl = `ADD;
		else if((is_func3 == `SUBI) & (is_func7 == 1'b1))
			o_alu_ctrl = `SUB;
		else if((is_func3 == `SRLI) & (is_func7 == 1'b0))
			o_alu_ctrl = `SRL;
		else if((is_func3 == `SRAI) & (is_func7 == 1'b1))
			o_alu_ctrl = `SRA;
		else if(is_func3 == `SLLI)
			o_alu_ctrl = `SLL;
		else if(is_func3 == `SLTI)
			o_alu_ctrl = `SLT;
		else if(is_func3 == `SLTUI)
			o_alu_ctrl = `SLTU;
		else if(is_func3 == `XORI)
			o_alu_ctrl = `XOR;
		else if(is_func3 == `ORI)
			o_alu_ctrl = `OR;
		else if(is_func3 == `ANDI)
			o_alu_ctrl = `AND;
		else
			o_alu_ctrl = 4'b1111; // invalid alu control signal	
	end
	else if(is_opcode == `I) begin
		if((is_func3 == `ADDI))
			o_alu_ctrl = `ADD;
		else if((is_func3 == `SRLI) & (is_func7 == 1'b0))
			o_alu_ctrl = `SRL;
		else if((is_func3 == `SRAI) & (is_func7 == 1'b1))
			o_alu_ctrl = `SRA;
		else if(is_func3 == `SLLI)
			o_alu_ctrl = `SLL;
		else if(is_func3 == `SLTI)
			o_alu_ctrl = `SLT;
		else if(is_func3 == `SLTUI)
			o_alu_ctrl = `SLTU;
		else if(is_func3 == `XORI)
			o_alu_ctrl = `XOR;
		else if(is_func3 == `ORI)
			o_alu_ctrl = `OR;
		else if(is_func3 == `ANDI)
			o_alu_ctrl = `AND;
		else
			o_alu_ctrl = 4'b1111; // invalid alu control signal	
	end
	else if((is_opcode == `LD) | (is_opcode == `S) | (is_opcode == `JR) | (is_opcode == `UPC)) begin
		o_alu_ctrl = `ADD;
	end
	else if((is_opcode == `J) | (is_opcode == `U)) begin
		o_alu_ctrl = `BUF;
	end
	else if(is_opcode == `B) begin
		if((is_func3 == `BEQ) | (is_func3 == `BNE))
			o_alu_ctrl = `EQ;
		else if((is_func3 == `BLT) | (is_func3 == `BGE))
			o_alu_ctrl = `GE;
		else if((is_func3 == `BLTU) | (is_func3 == `BGEU))
			o_alu_ctrl = `GEU;
		else
			o_alu_ctrl = 4'b1111; // invalid alu control signal
	end
    end
    
endmodule
