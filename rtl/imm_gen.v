`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"

module imm_gen(
    input wire clk,
    input wire rst_n,
    input wire [31:0] i_Instr,
    output wire [31:0] imm_data // Changed to reg for sequential logic
);

    // Internal signals
    wire [6:0] opcode;    // Extracted opcode

    // Extract opcode
    assign opcode = i_Instr[6:0];

    // Combinational logic for immediate data
    assign imm_data = (opcode == `I || opcode == `LD || opcode == `JR) ? {{20{i_Instr[31]}}, i_Instr[31:20]} : // I-type
                      (opcode == `S) ? {{20{i_Instr[31]}}, i_Instr[31:25], i_Instr[11:7]} :                 // S-type
                      (opcode == `B) ? {{19{i_Instr[31]}}, i_Instr[31], i_Instr[7], i_Instr[30:25], i_Instr[11:8], 1'b0} : // B-type
                      (opcode == `J) ? {{11{i_Instr[31]}}, i_Instr[31], i_Instr[19:12], i_Instr[20], i_Instr[30:21], 1'b0} : // J-type
                      (opcode == `U || opcode == `UPC) ? {i_Instr[31:12], 12'b0} :                              // U-type
                      32'h00000000; // Default for undefined opcodes

endmodule
