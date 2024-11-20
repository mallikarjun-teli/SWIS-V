`timescale 1ns / 1ps
`default_nettype none
`include "IF.v"
`include "ID.v"
`include "EX.v"
`include "MEM.v"
`include "WB.v"
	
module core(
input wire clk,
input wire rst_n,
input wire [31:0] i_i_data, // data read from i-mem
input wire [31:0] i_d_data, // data read from d-mem
input wire i_i_ack, // ack from i-mem
input wire i_d_ack, // ack from d-mem
output wire o_i_stb, // stub signal for i-mem (to read)
output wire o_d_stb, // stub signal for d-mem (to read)
output wire o_d_wr_en, // write enable signal for d-mem
output wire [31:0] o_d_write_data, // data to be written to d-mem
output wire [31:0] o_i_addr, // address for i-mem
output wire [31:0] o_d_addr, // address for d-mem
output wire [31:0] ex_result
);

//// IF ////
wire [31:0] if_instr, if_Pc;

IF if_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_Inst(i_i_data),  
    .i_Imem_ack(i_i_ack),     
    .o_Imem_stb(o_i_stb),     
    .o_Iaddr(o_i_addr),
    .i_Imm(ex_imm_data),
    .i_Result(ex_result),
    .i_Boj(ex_boj),
    .i_Jalr(ex_jalr),
    .o_InstrD(if_instr),
    .o_PcD(if_Pc)
);

//// ID ////
wire [31:0] id_rs1_data, id_rs2_data, id_imm_data, id_pc;
wire [6:0] id_opcode;
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

ID id_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_Instr(if_instr), 
    .i_Pc(if_Pc), 
    .i_write_data(data), 
    .i_wr(regsrc), 
    .o_OpE(id_opcode), 
    .o_Func3E(id_func3),  
    .o_RS1E(id_rs1_data), 
    .o_RS2E(id_rs2_data), 
    .o_ImmE(id_imm_data),
    .o_PcE(id_pc), 
    .o_RegSrc(id_regSrc),
    .o_Sel1E(id_sel1),
    .o_Sel2E(id_sel2),
    .o_ALUCtrlE(id_alu_ctrl), 
    .o_LoadE(id_load),
    .o_BranchE(id_branch),
    .o_JalE(id_jal),
    .o_JalrE(id_jalr), 
    .o_MemSrcE(id_memSrc),
    .o_ResultSrcE(id_resultSrc)     
);

//// EX ////
wire [31:0] ex_pc, ex_imm_data, ex_data_store;
wire [2:0] ex_func3;
wire ex_load;
wire ex_boj;
wire ex_jalr;
wire ex_regsrc;
wire ex_memsrc;
wire [1:0] ex_resultsrc;

EX ex_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_rs1_data(id_rs1_data),
    .i_rs2_data(id_rs2_data),
    .i_Pc(id_pc),
    .i_AluCtrl(id_alu_ctrl),
    .i_Func3(id_func3),
    .i_RegSrc(id_regSrc),
    .i_Imm(id_imm_data),
    .i_Sel1(id_sel1),
    .i_Sel2(id_sel2),
    .i_Load(id_load),
    .i_Branch(id_branch),
    .i_Jal(id_jal),
    .i_Jalr(id_jalr),
    .i_MemSrc(id_memSrc),
    .i_ResultSrc(id_resultSrc),
    .o_DataStoreW(ex_data_store),
    .o_ResultW(ex_result),
    .o_Func3W(ex_func3),
    .o_RegSrcW(ex_regsrc),
    .o_MemSrcW(ex_memsrc),
    .o_ResultSrcW(ex_resultsrc),
    .o_PcW(ex_pc),
    .o_Load(ex_load),
    .o_Boj(ex_boj),
    .o_Jalr(ex_jalr),
    .o_Imm_data(ex_imm_data)
);

//// MEM ////
wire wb_regSrc;
wire [1:0] wb_resultsrc;
wire [31:0] wb_result;
wire [31:0] wb_data;
wire [31:0] wb_pc4;

MEM mem_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_Result(ex_result),
    .i_DataStore(ex_data_store),
    .i_Pc(ex_pc),
    .i_Func3(ex_func3),
    .i_Load(ex_load),
    .i_MemSrc(ex_memsrc),
    .i_ResultSrc(ex_resultsrc),
    .i_RegSrc(ex_regsrc),
    .o_RegSrcW(wb_regSrc),
    .o_ResultSrcW(wb_resultsrc),
    .o_ResultW(wb_result),
    .o_DataW(wb_data),
    .o_Pc4W(wb_pc4),
    .i_rd_ack(i_d_ack),
    .i_read_data(i_d_data),
    .o_stb(o_d_stb),
    .o_MemSrc(o_d_wr_en),
    .o_addr(o_d_addr),
    .o_wr_data(o_d_write_data)
);

//// WB ////
wire regsrc;
wire [31:0] data;

WB wb_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_RegSrc(wb_regSrc),
    .i_ResultRrc(wb_resultsrc),
    .i_Result(wb_result),
    .i_Wb_Data(wb_data),
    .i_Pc_4(wb_pc4),
    .o_RegSrc(regsrc), 
    .o_Wb_data(data) 
);

endmodule
