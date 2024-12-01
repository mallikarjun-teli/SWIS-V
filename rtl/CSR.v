`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"


module CSR(
    input wire i_clk, 
    input wire i_rst_n,
    // Interrupts
    input wire i_external_interrupt, 
    input wire i_software_interrupt, 
    // Exceptions
    input wire i_is_inst_illegal, 
    input wire i_is_ecall, 
    input wire i_is_ebreak, 
    input wire i_is_mret,
    // Load/Store Misaligned
    input wire[6:0] i_opcode, //opcode types
    input wire[31:0] i_y, //y value from ALU (address used in load/store/jump/branch)
    // CSR Instruction 
    input wire[2:0] i_funct3, // CSR instruction operation
    input wire[11:0] i_csr_index, // immediate value from decoder
    input wire[31:0] i_imm, //unsigned immediate for immediate type of CSR instruction (new value to be stored to CSR)
    input wire[31:0] i_rs1, //Source register 1 value (new value to be stored to CSR)
    output reg[31:0] o_csr_out, //CSR value to be loaded to basereg 
    // Trap-Handler 
    input wire[31:0] i_pc, //Program Counter 
    input wire writeback_change_pc, //high if writeback will issue change_pc (which will override this stage)
    output reg[31:0] o_return_address, //mepc CSR
    output reg[31:0] o_trap_address, //mtvec CSR
    output reg o_go_to_trap_q, //high before going to trap (if exception/interrupt detected)
    output reg o_return_from_trap_q, //high before returning from trap (via mret)
    input wire i_minstret_inc //increment minstret after executing an instruction
    );

    // CSR registers
    reg [31:0] MVENDORID_reg;
    reg [31:0] MARCHID_reg;
    reg [31:0] MIMPID_reg;
    reg [31:0] MHARTID_reg;
    reg [31:0] MSTATUS_reg;
    reg [31:0] MISA_reg;
    reg [31:0] MIE_reg;
    reg [31:0] MTVEC_reg;
    reg [31:0] MSCRATCH_reg;
    reg [31:0] MEPC_reg;
    reg [31:0] MCAUSE_reg;
    reg [31:0] MTVAL_reg;
    reg [31:0] MIP_reg;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset all registers
            MVENDORID_reg <= 32'h0;
            MARCHID_reg <= 32'h0;
            MIMPID_reg <= 32'h0;
            MHARTID_reg <= 32'h0;
            MSTATUS_reg <= 32'h0;
            MISA_reg <= 32'h0;
            MIE_reg <= 32'h0;
            MTVEC_reg <= 32'h0;
            MSCRATCH_reg <= 32'h0;
            MEPC_reg <= 32'h0;
            MCAUSE_reg <= 32'h0;
            MTVAL_reg <= 32'h0;
            MIP_reg <= 32'h0;
            // Reset trap-related signals
            o_go_to_trap_q <= 0;
            o_return_from_trap_q <= 0;
        end else begin
            // Update CSR registers based on CSR instructions
            if (i_ce && !i_stall) begin
                case (i_csr_index)
                    MVENDORID: MVENDORID_reg <= csr_in;
                    MARCHID: MARCHID_reg <= csr_in;
                    MIMPID: MIMPID_reg <= csr_in;
                    MHARTID: MHARTID_reg <= csr_in;
                    MSTATUS: MSTATUS_reg <= csr_in;
                    MISA: MISA_reg <= csr_in;
                    MIE: MIE_reg <= csr_in;
                    MTVEC: MTVEC_reg <= csr_in;
                    MSCRATCH: MSCRATCH_reg <= csr_in;
                    MEPC: MEPC_reg <= csr_in;
                    MCAUSE: MCAUSE_reg <= csr_in;
                    MTVAL: MTVAL_reg <= csr_in;
                    MIP: MIP_reg <= csr_in;
                endcase
                // Handle trap-related signals
                if (go_to_trap && !o_go_to_trap_q) begin
                    o_return_address <= i_pc;
                    o_trap_address <= MTVEC_reg;
                end
                if (i_is_mret) begin
                    o_return_from_trap_q <= 1;
                end
            end
        end
    end

    // Control logic for detecting traps
    always @* begin
        // Detect external interrupt
        if (i_external_interrupt && MIE_reg[11]) begin
            go_to_trap = 1;
        end
        // Detect software interrupt
        else if (i_software_interrupt && MIE_reg[3]) begin
            go_to_trap = 1;
        end
        // Detect timer interrupt
        else if (i_timer_interrupt && MIE_reg[7]) begin
            go_to_trap = 1;
        end
        // Detect exceptions
        else if (i_is_inst_illegal || i_is_ecall || i_is_ebreak) begin
            go_to_trap = 1;
        end
        else begin
            go_to_trap = 0;
        end
    end

    // CSR instruction execution
    reg [31:0] csr_in;
    always @* begin
        case (i_funct3)
            3'b011: csr_in = i_rs1; // CSR read-write
            3'b010: csr_in = MSTATUS_reg | i_rs1; // CSR read-set
            3'b001: csr_in = MSTATUS_reg & (~i_rs1); // CSR read-clear
            3'b101: csr_in = i_imm; // CSR read-write immediate
            3'b110: csr_in = MSTATUS_reg | i_imm; // CSR read-set immediate
            3'b111: csr_in = MSTATUS_reg & (~i_imm); // CSR read-clear immediate
            default: csr_in = 32'h0;
        endcase
    end

endmodule

