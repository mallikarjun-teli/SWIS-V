`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module MEM(
input wire clk,
input wire rst_n,
input wire [31:0] i_result,
input wire [31:0] i_data_store,
input wire [31:0] i_pc,
input wire [6:0] i_opcode,
input wire [2:0] i_func3,
input wire i_jal,
input wire i_jalr,
input wire [1:0] i_resultsrc;
input wire i_RegSrc;
output wire [31:0] DataWb, // write back value can be result, data read or pc depending on the opcode
output wire [6:0] OpcodeWb,
// Data memory interface
input wire i_rd_ack, //ack from data memory
input wire [31:0] i_read_data, //data read from data memory
input wire i_wr_en,
output wire o_stb,
output wire o_wr_en,
output wire [31:0] o_addr,
output wire [31:0] o_wr_data,
output wire [31:0] o_pc_4,
output wire [31:0] o_result,
output wire [1:0] o_resultsrc,
output wire o_RegSrc
);

wire is_stall;

wire [31:0] o_wb_data;
wire [6:0] o_opcode;

reg [31:0] WbData_reg;
reg [6:0] Opcode_reg;

//only for simulation
`ifdef SIM
integer fd;
`endif

assign is_stall = ~i_rd_ack & rst_n;




// data going to WB stage
assign o_RegSrc = i_RegSrc;
assign o_opcode = i_opcode;
assign o_wb_data = (i_func3 == `LB) ? {{24{i_read_data[7]}},i_read_data[7:0]} : ((i_func3 == `LH) ? {{16{i_read_data[15]}},i_read_data[15:0]} : ((i_func3 == `LBU)? {24'd0,i_read_data[7:0]} : ((i_func3 == `LHU) ? {16'd0,i_read_data[15:0]} : i_read_data)));
assign o_result = i_result;
assign o_pc_4 = i_pc + 32'd4; // for jal and jalr instrction, pc+4 must be stored in rd
assign o_resultsrc = i_resultsrc;

// for data memory
assign o_stb = (i_opcode == `LD) ? 1'b1 : 1'b0;
assign o_wr_en = i_wr_en;
assign o_addr = (o_stb | o_wr_en | ~rst_n) ? i_result : 32'd0;
assign o_wr_data = (i_func3[1:0] == 2'b00) ? {24'd0,i_data_store[7:0]} : ((i_func3[1:0] == 2'b01) ? {16'd0,i_data_store[15:0]} : i_data_store); // for SW, SH and SB 

always @(posedge clk)
begin
	if(rst_n)
	begin
		Opcode_reg <= 32'b0;
		WbData_reg <= 32'b0;
	end
	else
	begin
		WbData_reg <= o_wb_data;
		Opcode_reg <= o_opcode;
	end
end

assign DataWb = WbData_reg;
assign OpcodeWb = Opcode_reg;

//only for simulation
`ifdef SIM
always @(posedge clk)
begin	
	#2
	if(o_stb)
	begin
		fd = $fopen("MEM_log.csv","ab+");
		$fwrite(fd,"mem:%h\n",o_addr);	
		$fclose(fd);
	end
	else
	begin
		fd = $fopen("MEM_log.csv","ab+");
		$fwrite(fd,"\t\n");	
		$fclose(fd);
	end
end
`endif

endmodule
