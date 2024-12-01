`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"
`include "../rtl/IF.v"
`include "../rtl/instr_mem.v"

module If(
    input wire clk,
    input wire rst_n,
    output wire [31:0] o_InstrD,
    output wire [31:0] o_PcD
);

  // Internal signals
  wire [31:0] o_data;       // Instruction fetched from instr_mem
  wire o_ack;               // Acknowledge signal from instr_mem
  wire [31:0] o_Iaddr;      // Instruction address from IF
  wire o_Imem_stb;          // Memory request signal from IF

  // Instantiate the IF module
  IF dut4 (
      .clk(clk),
      .rst_n(rst_n),
      .i_Inst(o_data),
      .i_Imem_ack(o_ack),
      .i_Imm(32'b0),           // Immediate value (set to 0 here; modify as needed)
      .i_Result(32'b0),        // Result input (set to 0 here; modify as needed)
      .i_Boj(1'b0), // Branch or Jump
      .i_Jalr(1'b0), // Jump and Link Register
      .o_Imem_stb(o_Imem_stb),
      .o_Iaddr(o_Iaddr),
      .o_InstrD(o_InstrD),
      .o_PcD(o_PcD)
  );

  // Instantiate the instr_mem module
  instr_mem dut5 (
      .clk(clk),
      .rst_n(rst_n),
      .i_addr(o_Iaddr),
      .i_stb(o_Imem_stb),
      .o_ack(o_ack),
      .o_data(o_data)
  );

endmodule
