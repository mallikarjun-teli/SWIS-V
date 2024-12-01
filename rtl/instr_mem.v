`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"

module instr_mem(
input wire clk,
input wire rst_n, // active low reset
input wire [31:0] i_addr, //instruction address
input wire i_stb, // request for instruction
output reg o_ack, // acknowledge signal
output reg [31:0] o_data //instruction code
);

reg [31:0] memory [1023:0];

initial
begin
	$readmemh("../rtl/riscvtest.txt",memory,0,20); // read instruction from the .mem file (byte wise)
end
always @(*)
begin
// Just for the simulation purpose, instruction memeory reads as soon as the address is inserted
	if(~rst_n) 
	begin
		o_ack = 1'b0;
		o_data = 32'd0;
	end
	else if(i_stb && ( (i_addr & 2'b11) == 2'b00 )) //checking is the stub signal is high and address is 4 bytes aligned(last two bits are zero)
	begin
		o_ack <= 1'b1; // acknowledge that the instruction is on the bus.
    	o_data <= memory [i_addr>>2]; // instructions are present byte wise and are in little-endian format
	end
	else
	begin
		if( (i_addr & 2'b11) != 2'b00 ) begin
			$display("\nINSTRUCTION MEMORY: Address %h is not 4-byte aligned!",i_addr);
		end 
		o_ack <= 1'b0;
		o_data <= 32'd0;
	end
end

endmodule
