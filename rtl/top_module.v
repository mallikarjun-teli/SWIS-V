`timescale 1ns / 1ps
`default_nettype none
`include "core.v"
`include "instr_mem.v"
`include "data_mem.v"

module top_module(
input wire clk,
input wire rst_n,
output wire [31:0] ex_result,
output wire [31:0] o_d_write_data,
output wire o_d_wr_en
);

wire [31:0] i_i_data;
wire [31:0] i_d_data;
wire i_i_ack;
wire i_d_ack;
wire o_i_stb;
wire o_d_stb;
//wire o_d_wr_en;
//wire [31:0] o_d_write_data;
wire [31:0] o_i_addr;
wire [31:0] o_d_addr;

core core_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_i_data(i_i_data),
    .i_d_data(i_d_data),
    .i_i_ack(i_i_ack),
    .i_d_ack(i_d_ack),
    .o_i_stb(o_i_stb),
    .o_d_stb(o_d_stb),
    .o_d_wr_en(o_d_wr_en),
    .o_d_write_data(o_d_write_data),
    .o_i_addr(o_i_addr),
    .o_d_addr(o_d_addr),
    .ex_result(ex_result)
);

data_mem data_mem_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_stb(o_d_stb),
    .i_wr_en(o_d_wr_en),
    .i_addr(o_d_addr),
    .i_write_data(o_d_write_data),
    .o_rd_ack(i_d_ack),
    .o_read_data(i_d_data)
);

instr_mem instr_mem_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_addr(o_i_addr),
    .i_stb(o_i_stb),
    .o_ack(i_i_ack),
    .o_data(i_i_data)
);

endmodule
