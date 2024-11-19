`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module imm_gen(
input wire [31:0] i_instr,
output reg [31:0] o_imm_data
);

reg [19:0] is_imm; // 20 bit immediate value. Entire 20-bits are used for U and J type and rest of the instruction use only 12-bits
wire [6:0] is_opcode;
wire [2:0] is_func3;

assign is_opcode = i_instr[6:0];

always @(*)
begin
    case(is_opcode)
    	`I:
    		begin
			is_imm = i_instr[31:20];
			o_imm_data = {{20{is_imm[11]}}, is_imm[11:0]};
    		end
	    `LD:
	    	begin
	    		is_imm = i_instr[31:20];
	    		o_imm_data = {{20{is_imm[11]}}, is_imm[11:0]};	
	    	end
	    `S:
	    	begin
	    		is_imm = {i_instr[31:25],i_instr[11:7]};
	    		o_imm_data = {{20{is_imm[11]}}, is_imm[11:0]};	
	    	end
	    `B:
	    	begin
	    		is_imm = {i_instr[31],i_instr[7],i_instr[30:25],i_instr[11:8],1'b0};
	    		o_imm_data = {{20{is_imm[12]}}, is_imm[11:0]};
	    	end
	    `J:
	    	begin
	    		is_imm = {i_instr[31],i_instr[19:12],i_instr[20],i_instr[30:21],1'b0};
	    		o_imm_data = {{12{is_imm[19]}},is_imm[19:0]};
	    	end
	    `JR:
	    	begin
	    		is_imm = i_instr[31:20];
	    		o_imm_data = {{20{is_imm[11]}}, is_imm[11:0]};
	    	end
	    `U:
	    	begin
	        	is_imm = i_instr[31:12];
	        	o_imm_data = {is_imm,12'd0};
	    	end
	    `UPC:
	    	begin
	            is_imm = i_instr[31:12];
	            o_imm_data = {is_imm,12'd0};
	    	end        
        default:
            begin
	    		is_imm = 20'd0;
	    		o_imm_data = 32'd0;
            end
    endcase
        
end

endmodule
