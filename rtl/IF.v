`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"

module IF(
input wire clk,
input wire rst_n,
input wire stall,
output wire [31:0] o_PcD, //Current PC value
output wire [31:0] o_InstrD,
//instruction memory interface
input wire [31:0] i_Inst, //instruction code received from the instruction memory
input wire i_Imem_ack, //ack by instruction memory (active high)
output reg o_Imem_stb, //stub signal for instruction memroy
output reg [31:0] o_Iaddr, //instruction address
//Change in PC
input wire [31:0] i_Imm,
input wire [31:0] i_Result,
input wire i_Boj,
input wire i_Jalr
);

//internal signals and registers
wire is_stall = (!i_Imem_ack & ~rst_n) || stall;
wire [31:0] is_pcnxt;
reg [31:0] pc;
reg [31:0] pc_reg;
reg [31:0] Instr_reg;


//only for simulation
`ifdef SIM
integer fd;
`endif


assign is_pcnxt = i_Boj ? i_Imm : pc + 32'd4;
assign o_PcD = pc_reg;
assign o_InstrD = Instr_reg;

always @(posedge clk)
begin
	if(~rst_n)
	begin
		pc <= `PC_RESET;
	end
	else if(is_stall)
	begin
		pc <= pc;
	end
	else
	begin
		pc <= is_pcnxt;
	end
end


always @(posedge clk)
begin
	if(~rst_n || i_Boj)
	begin
		pc_reg <= `PC_RESET;
		Instr_reg = `NOP;
	end
	else if(is_stall)
	begin
		pc_reg <= pc_reg;
		Instr_reg = Instr_reg;
	end
	/*else if(i_Jalr)
	begin
		pc_reg <= i_Result &~1;	
	end*/
	else
	begin
		pc_reg <= pc;
		Instr_reg = i_Inst;
	end
end

always @(*)
begin
	if(~rst_n)
	begin
		o_Iaddr = 32'd0;
		o_Imem_stb = 1'b0;
	end
	else
	begin
		o_Iaddr = pc;
		o_Imem_stb = 1'b1;
	end
end

//only for simulation
`ifdef SIM
always @(o_PcD,Instr_reg)
begin	
	#2
	if(rst_n & o_Imem_stb)
	begin
		fd = $fopen("IF_log.csv","ab+");
		$fwrite(fd,"%h,%h\n",o_PcD,Instr_reg);
		$fclose(fd);
	end
end

`endif

endmodule

