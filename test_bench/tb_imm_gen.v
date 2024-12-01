`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/imm_gen.v"

module tb_imm_gen;

  reg clk;
  reg rst_n;
  reg [31:0] i_instr;
  wire [31:0] o_imm_data;

  // Instantiate the imm_gen module
  imm_gen uut (
    .clk(clk),
    .rst_n(rst_n),
    .i_Instr(i_instr),
    .o_ImmE(o_imm_data)
  );

  always #5 clk =~clk;

  // Testbench stimulus
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_imm_gen);
    clk = 0;
    rst_n = 0;
    #5
    rst_n =1;
  #10
  i_instr = 32'h00500113;
  #10   
  i_instr = 32'h00C00193;
  #10
  i_instr = 32'hFF718393;
  #10
  i_instr = 32'h0023E233;
  #10
  i_instr = 32'h0041F2B3;
  #10
  i_instr = 32'h004282B3;
  #10
  i_instr = 32'h02728863;
  #10
  i_instr = 32'h0041A233;
  #10
  i_instr = 32'h00010463;
  #10
  i_instr = 32'h00000293;
  #10
  i_instr = 32'h0023A233;
  #10
  i_instr = 32'h005103B3;
  #10
  i_instr = 32'h402383B3;
  #10
  i_instr = 32'h0471AA23;
  #10
  i_instr = 32'h06002103;
  #10
  i_instr = 32'h005104B3;
  #10
  i_instr = 32'h008001EF;
  #10
  i_instr = 32'h00100113;
  #10
  i_instr = 32'h00910133;
  #10
  i_instr = 32'h0221A023;
  #10
  i_instr = 32'h00210063;
  #10

    // Add more test vectors as needed

    // Finish simulation
    $finish;
  end

endmodule
