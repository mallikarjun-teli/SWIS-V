module hazard_unit(
    input wire [4:0] is_Rs1,
    input wire [4:0] is_Rs2,
    input wire [4:0] a1, a2,
    input wire ex_regsrc, // EX stage register source valid signal
    input wire m_regsrc,  // MEM stage register source valid signal
    input wire [4:0]id_rd,
    input wire [4:0] ex_rd, // Destination register in EX stage
    input wire [4:0] mem_rd, // Destination register in MEM stage
    input wire load,
    output wire load_use_hazard,
    output wire [1:0] mux1_sel, // Forwarding selection for source 1
    output wire [1:0] mux2_sel  // Forwarding selection for source 2
);

assign load_use_hazard = ((is_Rs1 == id_rd) | (is_Rs2 == id_rd)) && load;

assign mux1_sel = (ex_regsrc && ex_rd != 0 && a1 == ex_rd) ? 2'b01 : 
                  (m_regsrc && mem_rd != 0 && a1 == mem_rd) ? 2'b10 : 
                  2'b00;

assign mux2_sel = (ex_regsrc && ex_rd != 0 && a2 == ex_rd) ? 2'b01 : 
                  (m_regsrc && mem_rd != 0 && a2 == mem_rd) ? 2'b10 : 
                  2'b00;
endmodule


