`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/IF.v"

module tb_IF;

  // Signals
  reg clk;
  reg rst_n;
  reg [31:0] i_Inst;
  reg i_Imem_ack;

  wire o_Imem_stb;
  wire [31:0] o_Iaddr;

  reg [31:0] i_Imm;
  reg [31:0] i_Result;
  reg i_Boj;
  reg i_Jalr;

  wire [31:0] o_PcD;
  wire [31:0] o_InstrD;



  // Instantiate the IF module
  IF dut (
    .clk(clk),
    .rst_n(rst_n),
    .o_PcD(o_PcD),
    .o_InstrD(o_InstrD),
    .i_Inst(i_Inst),
    .i_Imem_ack(i_Imem_ack),
    .o_Imem_stb(o_Imem_stb),
    .o_Iaddr(o_Iaddr),
    .i_Imm(i_Imm),
    .i_Result(i_Result),
    .i_Boj(i_Boj),
    .i_Jalr(i_Jalr)
  );


  // Test case
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_IF);
    // Initializing inputs
    clk  = 0;
    rst_n = 0;

    i_Inst = 32'h00106293;
    i_Imem_ack = 1;

    i_Imm = 32'hc;
    i_Result = 32'hf;

    i_Boj = 0;
    i_Jalr = 0;

    // Reset sequence
    #10;
    rst_n = 1;
    // Test sequence
    // Stimulus for PC change
    #10;
    i_Boj = 1;
    #20;
    // De-asserting inputs
    i_Boj = 0;
    i_Jalr = 1;
    #20;
    i_Jalr = 0;
    #100;
    // More test cases can be added similarly to cover various scenarios

    // Finishing simulation
    $finish;
  end

  // Clock generation process
  always #5 clk = ~clk;

endmodule

