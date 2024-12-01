`timescale 10ns / 1ps
`include "../rtl/ID.v"
module tb_ID;

  reg clk;
  reg rst_n;
  reg [31:0] i_Instr;
  reg [31:0] i_write_data;
  reg [31:0] i_Pc;
  reg i_wr;
  wire [2:0] o_Func3E;
  wire [31:0] o_RS1E;
  wire [31:0] o_RS2E;
  wire [31:0] o_ImmE;
  wire [31:0] o_PcE;
  wire o_RegSrcE;
  wire o_Sel1E;
  wire o_Sel2E;
  wire [3:0] o_ALUCtrlE;
  wire o_LoadE;
  wire o_BranchE;
  wire o_JalE;
  wire o_JalrE;
  wire o_MemSrcE;
  wire [1:0] o_ResultSrcE;
  wire [6:0] is_Opcode;

  // Instantiate the module
  ID id_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_Instr(i_Instr),
    .i_write_data(i_write_data),
    .i_Pc(i_Pc),
    .i_wr(i_wr),
    .o_Func3E(o_Func3E),
    .o_RS1E(o_RS1E),
    .o_RS2E(o_RS2E),
    .o_ImmE(o_ImmE),
    .o_PcE(o_PcE),
    .o_RegSrcE(o_RegSrcE),
    .o_Sel1E(o_Sel1E),
    .o_Sel2E(o_Sel2E),
    .o_ALUCtrlE(o_ALUCtrlE),
    .o_LoadE(o_LoadE),
    .o_BranchE(o_BranchE),
    .o_JalE(o_JalE),
    .o_JalrE(o_JalrE),
    .o_MemSrcE(o_MemSrcE),
    .o_ResultSrcE(o_ResultSrcE),
    .is_Opcode(is_Opcode)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial values
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_ID);
    clk = 0;
    rst_n = 0;
    i_Instr = 32'b0;
    i_write_data = 32'h501248;
    i_Pc = 32'h0;
    i_wr = 1;

    #10; // Wait for a few clock cycles before toggling reset

    rst_n = 1;
    end
    always @(posedge clk)
    begin
    
    #20; // Provide some time after releasing reset
/*
    // Test cases with instructions
    // Example 1
    i_Instr = 32'h7FF00293; // addi x5 x0 2047
    #10;
    // Provide other test case sequences similarly
    // Example 2
    i_Instr = 32'h00530333; // add x6 x6 x5
    #10;

    // Example 3
    i_Instr = 32'hFE5FF3EF; // jal x7 -28
    #10;

    // Example 4
    i_Instr = 32'h0063D863; // bge x7 x6 16
    #10;

    // Add more test cases if needed
*/
    i_Instr = 32'h00500113;
    #10   
    i_Instr = 32'h00C00193;
    #10
    i_Instr = 32'hFF718393;
    #10
    i_Instr = 32'h0023E233;
    #10
    i_Instr = 32'h0041F2B3;
    #10
    i_Instr = 32'h004282B3;
    #10
    i_Instr = 32'h02728863;
    #10
    i_Instr = 32'h0041A233;
    #10
    i_Instr = 32'h00020463;
    #10
    i_Instr = 32'h00000293;
    #10
    i_Instr = 32'h0023A233;
    #10
    i_Instr = 32'h005203B3;
    #10
    i_Instr = 32'h402383B3;
    #10
    i_Instr = 32'h0471AA23;
    #10
    i_Instr = 32'h06002103;
    #10
    i_Instr = 32'h005104B3;
    #10
    i_Instr = 32'h008001EF;
    #10
    i_Instr = 32'h00100113;
    #10
    i_Instr = 32'h00910133;
    #10
    i_Instr = 32'h0221A023;
    #10
    i_Instr = 32'h00210063;
    #10
    // Finish the simulation
    #300;
    

    $finish;
  end

  // Add stimulus or other test bench code if needed

endmodule

