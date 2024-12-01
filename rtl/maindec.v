`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"

module maindec(
    input wire clk,
    input wire rst_n,
    input wire [6:0] i_opcode,
    output wire o_RegSrcE,
    output wire o_Sel1E,
    output wire o_Sel2E,
    output wire o_LoadE,
    output wire o_BranchE,
    output wire o_JalE,
    output wire o_JalrE,
    output wire o_MemSrcE,
    output wire [1:0] o_ResultSrcE
);

reg o_regSrc_reg;
reg o_selop1_reg;
reg o_selop2_reg;
reg o_load_reg;
reg o_branch_reg;
reg o_jal_reg;
reg o_jalr_reg;
reg o_wr_en_reg;
reg [1:0] o_resultsrc_reg;

wire regSrc;
wire selop1;
wire selop2;
wire load;
wire branch;
wire jal;
wire jalr;
wire wr_en;
wire [1:0] resultsrc;

assign regSrc = ((i_opcode == `B) | (i_opcode == `S)) ? 1'b0 : 1'b1;
assign selop1 = (i_opcode == `UPC | i_opcode == `B | i_opcode == `J) ? 0 :1;
assign selop2 = (i_opcode == `R ) ? 0 : 1;
assign load = (i_opcode == `LD) ? 1'b1 : 1'b0;
assign branch = (i_opcode == `B) ? 1 :0;
assign jal = (i_opcode == `J) ? 1 :0;
assign jalr = (i_opcode == `JR) ? 1 :0;
assign wr_en = (i_opcode == `S) ? 1 :0;
assign resultsrc = ((i_opcode == `J) | (i_opcode == `JR)) ? 2'b10 : ((i_opcode == `LD) ? 2'b01 : 2'b00);

always @(posedge clk)
begin
    if(~rst_n) begin
        o_regSrc_reg <= 1'b0;
        o_selop1_reg <= 1'b0;
        o_selop2_reg <= 1'b0;
        o_load_reg <= 1'b0;
        o_branch_reg <= 1'b0;
        o_jal_reg <= 1'b0;
        o_jalr_reg <= 1'b0;
        o_wr_en_reg <= 1'b0;
        o_resultsrc_reg <= 2'b0;
    end
    else begin
        o_regSrc_reg <= regSrc;
        o_selop1_reg <= selop1;
        o_selop2_reg <= selop2;
        o_load_reg <= load;
        o_branch_reg <= branch;
        o_jal_reg <= jal;
        o_jalr_reg <= jalr;
        o_wr_en_reg <= wr_en;
        o_resultsrc_reg <= resultsrc;
    end
end

assign o_RegSrcE = o_regSrc_reg;
assign o_Sel1E = o_selop1_reg;
assign o_Sel2E = o_selop2_reg;
assign o_LoadE = o_load_reg;
assign o_BranchE = o_branch_reg;
assign o_JalE = o_jal_reg;
assign o_JalrE = o_jalr_reg;
assign o_MemSrcE = o_wr_en_reg;
assign o_ResultSrcE = o_resultsrc_reg;


endmodule
