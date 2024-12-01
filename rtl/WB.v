`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"

module WB (
    input wire clk,
    input wire rst_n,
    input wire i_RegSrc,            // Write enable for registers from memory stage
    input wire [4:0] i_Rd,          // Destination register from memory stage
    input wire [1:0] i_ResultSrc,   // Output selector
    input wire [31:0] i_Result,     // Result from ALU
    input wire [31:0] i_Wb_Data,    // Result from data memory
    input wire [31:0] i_Pc_4,       // PC + 4

    output wire [4:0] o_Rd,         // Destination register to register file
    output wire o_RegSrc,           // Write enable for registers to register file
    output wire [31:0] o_Wb_data    // Data to store in register
);

    // Forward control and destination register
    assign o_Rd = i_Rd;
    assign o_RegSrc = i_RegSrc;

    // Multiplexer for selecting data to write back
    wire [31:0] wb_data_mux;
    assign wb_data_mux = (i_ResultSrc == 2'b00) ? i_Result : 
                         (i_ResultSrc == 2'b01) ? i_Wb_Data : 
                         (i_ResultSrc == 2'b10) ? i_Pc_4 : 32'd0;

    // Gated write-back data
    assign o_Wb_data = (rst_n) ? wb_data_mux : 32'd0;

endmodule
