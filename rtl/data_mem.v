`timescale 1ns / 1ps
`include "parameters.vh"
`default_nettype none

module data_mem(
input wire clk,
input wire rst_n,
input wire i_stb,
input wire i_wr_en,
input wire [31:0] i_addr,
input wire [31:0] i_write_data,
output wire o_rd_ack,
output wire [31:0] o_read_data
);

reg [7:0] memory[1023:0]; // byte adressable

integer fd;

// Reading (Asynchronous)
assign o_rd_ack = ~rst_n ? 1'b0 : 1'b1;
assign o_read_data = (rst_n & i_stb) ? {memory[i_addr+3],memory[i_addr+2],memory[i_addr+1],memory[i_addr]} : 32'd0;

/*
//only for simulation
always @(posedge clk)
begin
	if(i_stb)
	begin
		fd = $fopen("data_memory.log","ab+");
    		if( (i_addr & 2'b11) != 2'b00 ) begin
			$display("\nDATA MEMORY: Address %h is not 4-byte aligned!",i_addr);
		end 	
    		$fdisplay(fd, "Data 0x%h Read from address 0x%h", {memory[i_addr+3],memory[i_addr+2],memory[i_addr+1],memory[i_addr]}, i_addr);
		$fclose(fd);
	end
end

always @(*)
begin
	if(~rst_n) 
	begin
		o_rd_ack <= 1'b0;
		o_read_data <= 32'd0;
	end
	else if(i_stb)
	begin
		o_rd_ack <= 1'b1; // acknowledge that the data is on the bus
    		o_read_data <= {memory[i_addr+3],memory[i_addr+2],memory[i_addr+1],memory[i_addr]}; // data is present byte wise and in little-endian format
    		
    		fd = $fopen("data_memory.log","ab+");
    		if( (i_addr & 2'b11) != 2'b00 ) begin
			$display("\nDATA MEMORY: Address %h is not 4-byte aligned!",i_addr);
		end 	
    		$fdisplay(fd, "Data 0x%h Read from address 0x%h", {memory[i_addr+3],memory[i_addr+2],memory[i_addr+1],memory[i_addr]}, i_addr);
		$fclose(fd);
	end
	else
	begin
		o_rd_ack <= 1'b0;
		o_read_data <= 32'd0;
	end
end
*/

// Writing
always @(posedge clk)
begin
	if(i_wr_en & rst_n) // if the write enable signal is high and reset is not pressed, write to the data memory
    	begin
	//	fd = $fopen("data_memory.log","ab+");	
	//	if( (i_addr & 2'b11) != 2'b00 ) begin
	//		$display("\nDATA MEMORY: Address %h is not 4-byte aligned!",i_addr);
	//	end 	
		memory[i_addr + 3] <= i_write_data[31:24];
		memory[i_addr + 2] <= i_write_data[23:16];
		memory[i_addr + 1] <= i_write_data[15:8];
		memory[i_addr] <= i_write_data[7:0];
	//	$fdisplay(fd, "Data 0x%h Written to the address 0x%h", i_write_data, i_addr);
	//	$fclose(fd);
	end
end

endmodule
