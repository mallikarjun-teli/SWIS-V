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
wire [31:0] o_InstrD, o_PcD;

IF if_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_inst(i_i_data),
    .i_imem_ack(i_i_ack),
    .o_imem_stb(o_i_stb),
    .o_iaddr(o_i_addr),
    .i_imm(ex_imm_data),
    .i_result(ex_result),
    .i_boj(ex_boj),
    .i_jalr(ex_jalr),
    .o_PcD(o_PcD),
    .o_InstrD(o_InstrD)
);

//// ID ////
wire [31:0] id_rs1_data, id_rs2_data, id_imm_data, id_pc;
wire [6:0] id_opcode;
wire [2:0] id_func3;
wire [3:0] id_alu_ctrl;

ID id_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_instr(o_InstrD),
    .i_write_data(wb_data),
    .i_pc(o_PcD),
    .i_wr(wb_rf_wr),
    .o_RS1E(id_rs1_data),
    .o_RS2E(id_rs2_data),
    .o_ImmE(id_imm_data),
    .o_OpE(id_opcode),
    .o_Func3E(id_func3),
    .o_ALUCtrlE(id_alu_ctrl),
    .o_PcE(id_pc)
    
);

//// EX ////
wire [31:0] ex_pc, ex_imm_data, ex_data_store;
wire [6:0] ex_opcode;
wire [2:0] ex_func3;
wire ex_boj;
wire ex_jalr;

EX ex_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_rs1_data(id_rs1_data),
    .i_rs2_data(id_rs2_data),
    .i_imm_data(id_imm_data),
    .i_pc(id_pc),
    .i_alu_ctrl(id_alu_ctrl),
    .i_func3(id_func3),
    .i_opcode(id_opcode),
    .o_ResultM(ex_result),
    .o_DatastoreM(ex_data_store),
    .o_PcM(ex_pc),
    .o_Func3M(ex_func3),
    .o_OpM(ex_opcode),
    .o_boj(ex_boj),
    .o_jalr(ex_jalr),
    .o_imm_data(ex_imm_data)
);

//// MEM ////
wire [31:0] mem_wb_data;
wire [6:0] mem_opcode;
wire mem_wr_en;

MEM mem_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_result(ex_result),
    .i_data_store(ex_data_store),
    .i_pc(ex_pc),
    .i_opcode(ex_opcode),
    .i_func3(ex_func3),
    .DataWb(mem_wb_data),
    .OpcodeWb(mem_opcode),
    .i_rd_ack(i_d_ack),
    .i_read_data(i_d_data),
    .o_stb(o_d_stb),
    .o_wr_en(o_d_wr_en),
    .o_addr(o_d_addr),
    .o_wr_data(o_d_write_data)
);

//// WB ////
wire wb_rf_wr;
wire [31:0] wb_data;

WB wb_module(
    .clk(clk),
    .rst_n(rst_n),
    .i_wb_data(mem_wb_data),
    .i_opcode(mem_opcode),
    .o_rf_wr(wb_rf_wr),
    .o_wb_data(wb_data)
);

endmodule
