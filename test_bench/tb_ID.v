`timescale 1ns / 1ps
`include "ID.v"
module tb_ID;

  reg clk;
  reg rst_n;
  reg [31:0] i_instr;
  reg [31:0] i_write_data;
  reg [31:0] i_pc;
  reg i_wr;
  wire [31:0] o_RS1E;
  wire [31:0] o_RS2E;
  wire [31:0] o_ImmE;
  wire [6:0] o_OpE;
  wire [2:0] o_Func3E;
  wire [3:0] o_ALUCtrlE;
  wire [31:0] o_PcE;

  // Instantiate the module
  ID id_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_instr(i_instr),
    .i_write_data(i_write_data),
    .i_pc(i_pc),
    .i_wr(i_wr),
    .o_RS1E(o_RS1E),
    .o_RS2E(o_RS2E),
    .o_ImmE(o_ImmE),
    .o_OpE(o_OpE),
    .o_Func3E(o_Func3E),
    .o_ALUCtrlE(o_ALUCtrlE),
    .o_PcE(o_PcE)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial values
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_ID);
    clk = 0;
    rst_n = 0;
    i_instr = 32'h7FF00293;
    i_write_data = 32'h0;
    i_pc = 32'h0;
    i_wr = 0;

    #10; // Wait for a few clock cycles before toggling reset

    rst_n = 1;
    #20; // Provide some time after releasing reset

    // Test cases with instructions
    // Example 1
    i_instr = 32'h7FF00293; // addi x5 x0 2047
    #10;
    // Provide other test case sequences similarly
    // Example 2
    i_instr = 32'h00530333; // add x6 x6 x5
    #10;

    // Example 3
    i_instr = 32'hFE5FF3EF; // jal x7 -28
    #10;

    // Example 4
    i_instr = 32'h0063D863; // bge x7 x6 16
    #10;

    // Add more test cases if needed

    // Finish the simulation
    #100;
    $finish;
  end

  // Add stimulus or other test bench code if needed

endmodule

