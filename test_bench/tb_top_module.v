`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/top_module.v"

module tb_top_module;

  // Declare signals
  reg clk;
  reg rst_n;
  wire [31:0] ex_result;
  wire [31:0] if_instr;
  wire [31:0] if_Pc;
  wire [31:0] id_rs1_data;
  wire [31:0] id_rs2_data;
  wire [31:0] id_imm_data;
  wire [31:0] id_pc;
  wire [2:0] id_func3;
  wire id_regSrc;
  wire id_sel1;
  wire id_sel2;
  wire id_load;
  wire id_branch;
  wire id_jal;
  wire id_jalr;
  wire id_memSrc;
  wire [1:0] id_resultSrc;
  wire [3:0] id_alu_ctrl;
  wire [31:0] ex_pc;
  wire [31:0] ex_imm_data;
  wire [31:0] ex_data_store;
  wire [2:0] ex_func3;
  wire ex_load;
  wire [31:0] result_to_if;
  wire ex_boj;
  wire ex_jalr;
  wire ex_regsrc;
  wire ex_memsrc;
  wire [1:0] ex_resultsrc;
  wire [4:0] m_rd;
  wire m_regSrc;
  wire [1:0]m_resultsrc;
  wire [31:0] m_result;
  wire [31:0] m_data;
  wire [31:0] m_pc4;
  wire w_regsrc;
  wire [31:0] w_data;
  wire [4:0] id_rd;
  wire [4:0] ex_rd;
  wire [4:0] w_rd;
  wire [31:0] fwdwire2, fwdwire1;
  wire o_load_use_hazard;/*
  wire [4:0] a1, a2;*/

  // Instantiate the top module
  top_module dut (
    .clk(clk),
    .rst_n(rst_n),
    .ex_result(ex_result),
    .if_instr(if_instr),
    .if_Pc(if_Pc),
    .id_rs1_data(id_rs1_data),
    .id_rs2_data(id_rs2_data),
    .id_imm_data(id_imm_data),
    .id_pc(id_pc),
    .id_func3(id_func3),
    .id_regSrc(id_regSrc),
    .id_sel1(id_sel1),
    .id_sel2(id_sel2),
    .id_load(id_load),
    .id_branch(id_branch),
    .id_jal(id_jal),
    .id_jalr(id_jalr),
    .id_memSrc(id_memSrc),
    .id_resultSrc(id_resultSrc),
    .id_alu_ctrl(id_alu_ctrl),
    .ex_pc(ex_pc),
    .ex_imm_data(ex_imm_data),
    .ex_data_store(ex_data_store),
    .ex_func3(ex_func3),
    .ex_load(ex_load),
    .result_to_if(result_to_if),
    .ex_boj(ex_boj),
    .ex_jalr(ex_jalr),
    .ex_regsrc(ex_regsrc),
    .ex_memsrc(ex_memsrc),
    .ex_resultsrc(ex_resultsrc),
    .m_regSrc(m_regSrc),
    .m_resultsrc(m_resultsrc),
    .m_result(m_result),
    .m_data(m_data),
    .m_pc4(m_pc4),
    .w_regsrc(w_regsrc),
    .w_data(w_data),
    .id_rd(id_rd),
    .ex_rd(ex_rd),
    .m_rd(m_rd),
    .w_rd(w_rd),
    .fwdwire2(fwdwire2),
    .fwdwire1(fwdwire1),
    .o_load_use_hazard(o_load_use_hazard)/*
    .a1(a1), 
    .a2(a2)*/
  );

// Clock generation
  always #5 clk = ~clk;

  // Initial block
  initial begin
    clk = 0;
    rst_n = 0;
    #10;
    rst_n = 1;
    #1000; // Simulate for 1000 time units

    // Finish simulation
    $finish;
  end

  // Dump waveform
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_top_module);
    #10; // Delay before dumping
  end

endmodule


  
