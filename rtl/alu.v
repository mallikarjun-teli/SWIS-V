`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module alu(
input wire [31:0] i_op1, //operand 1
input wire [31:0] i_op2, //operand 2
input wire [3:0] i_alu_ctrl, //ALU control signal
output reg [31:0] o_result //ALU result
);

always @(*)
begin
    case(i_alu_ctrl)        
        `ADD:
        	o_result = $signed(i_op1) + $signed(i_op2);
        `SUB:
	    	o_result = $signed(i_op1) - $signed(i_op2);
        `AND:
            	o_result = i_op1 & i_op2;
        `OR:
            	o_result = i_op1 | i_op2;
        `XOR:
            	o_result = i_op1 ^ i_op2;
        `SRL:
            	o_result = i_op1 >> i_op2[4:0]; //Only last bits of the operand 2 is used to shift(defined by RISC-V)
        `SLL:
            	o_result = i_op1 << i_op2[4:0];
        `SRA:
            	o_result = $signed(i_op1) >>> i_op2[4:0];
        `BUF:
            	o_result = $signed(i_op2);
    	`SLT:
    		o_result = (i_op1[31] ^ i_op2[31])? {31'd0,i_op1[31]} : {31'd0,$signed(i_op1) < $signed(i_op2)};
    	`SLTU:
    		o_result = {31'd0,$signed(i_op1) < $signed(i_op2)};
    	`EQ:
    		o_result = {31'd0, (i_op1 == i_op2)};
    	`GE:
    		o_result = (i_op1[31] ^ i_op2[31])? {31'd0, i_op2[31]} : {31'd0, ($signed(i_op1) >= $signed(i_op2))};
    	`GEU:
    		o_result = {31'd0, ((i_op1) >= (i_op2))};
        default:
            	o_result <= 32'd0;
    endcase
end

endmodule
