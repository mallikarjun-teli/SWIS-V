`timescale 1ns / 1ps

module csr_ssm_tb();

parameter TRAP_ADDRESS = 32'h00000000;
    //Inputs
    reg i_clk;
    reg i_rst_n;
    reg i_external_interrupt;
    reg i_software_interrupt;
    reg i_is_inst_illegal;
    reg i_is_ecall;
    reg i_is_ebreak;
    reg i_is_mret;
    reg [`OPCODE_WIDTH-1:0] i_opcode;
    reg [31:0] i_y;
    reg [2:0] i_funct3;
    reg [11:0] i_csr_index;
    reg [31:0] i_imm;
    reg [31:0] i_rs1;
    reg [31:0] i_pc;
    reg writeback_change_pc;
     reg is_load_addr_misaligned; 
    reg is_store_addr_misaligned;
    reg is_inst_addr_misaligned;
    reg external_interrupt_pending; 
    reg software_interrupt_pending;
    reg is_interrupt;
    reg is_exception;
    reg is_trap;
    reg update_enable;
    reg mstatus_mie; //Machine Interrupt Enable
    reg mstatus_mpie; //Machine Previous Interrupt Enable
    reg[1:0] mstatus_mpp; //MPP
    reg mie_meie; //machine external interrupt enable
    reg mie_msie; //machine software interrupt enable
    reg[29:0] mtvec_base; //address of i_pc after returning from interrupt (via MRET)
    reg[1:0] mtvec_mode; //vector mode addressing 
    reg[31:0] mscratch; //dedicated for use by machine code
    reg[31:0] mepc; //machine exception i_pc (address of interrupted instruction)
    reg mcause_intbit; //interrupt(1) or exception(0)
    reg[3:0] mcause_code; //indicates event that caused the trap
    reg[31:0] mtval; //exception-specific infotmation to assist software in handling trap
    reg mip_meip; //machine external interrupt pending
    reg mip_mtip; //machine timer interrupt pending
    reg mip_msip; //machine software interrupt pending


    // Outputs
    wire [31:0] o_csr_out;
    wire [31:0] o_return_address;
    wire [31:0] o_trap_address;
    wire o_go_to_trap_q;
    wire o_return_from_trap_q;

       // Instantiate the Unit Under Test (UUT)
    csr_ssm #(.TRAP_ADDRESS(TRAP_ADDRESS))
     dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_external_interrupt(i_external_interrupt),
        .i_software_interrupt(i_software_interrupt),
        .i_is_inst_illegal(i_is_inst_illegal),
        .i_is_ecall(i_is_ecall),
        .i_is_ebreak(i_is_ebreak),
        .i_is_mret(i_is_mret),
        .i_opcode(i_opcode),
        .i_y(i_y),
        .i_funct3(i_funct3),
        .i_csr_index(i_csr_index),
        .i_imm(i_imm),
        .i_rs1(i_rs1),
        .o_csr_out(o_csr_out),
        .i_pc(i_pc),
        .writeback_change_pc(writeback_change_pc),
        .o_return_address(o_return_address),
        .o_trap_address(o_trap_address),
        .o_go_to_trap_q(o_go_to_trap_q),
        .o_return_from_trap_q(o_return_from_trap_q)
    ); 

    initial 
        begin
          i_clk = 0;
        end
    always
    #5
        i_clk = ~i_clk;

    initial
     begin
        
        $dumpfile("waveform.vcd");
        $dumpvars(0,csr_ssm_tb);
    end

    initial
    begin
        // Initialize inputs
        i_rst_n = 0;
        i_external_interrupt = 0;
        i_software_interrupt = 0;
      
        i_is_inst_illegal = 0;
        i_is_ecall = 0;
        i_is_ebreak = 0;
        i_is_mret = 0;
        i_opcode = 0;
        i_y = 0;
        i_funct3 = 0;
        i_csr_index = 0;
        i_imm = 0;
        i_rs1 = 0;
        i_pc = 0;
        writeback_change_pc = 0;
        i_opcode = 7'b1110011;

        // Apply reset
        #10 i_rst_n = 1; 

        // Test illegal instruction exception
        #10 i_is_inst_illegal = 1; //mcause code 2 mcause_init_bit 0 and isexception will be high
            i_pc = 32'h00001000;
        #10 i_is_inst_illegal = 0;  

        // Test CSR read-write (CSRRW)
        #10 
            
            i_funct3 = 3'b001;
            i_csr_index = 12'h300; // MSTATUS
            i_rs1 = 32'h00000008; // Write MIE bit
        #10 i_funct3 = 0;

        // Test CSR read-set (CSRRS)
        #10 i_funct3 = 3'b010;
            i_csr_index = 12'h304; // MIE
            i_rs1 = 32'h00000808; // Set MSIE and MEIE bits
        #10 i_funct3 = 0;

            #10 i_funct3 = 3'b101;
            i_csr_index = 12'h305; // MTVEC
            i_imm = 32'h00000002; // Write to MTVEC
        #10 i_funct3 = 0;




        // Test external interrupt
        //sets mip_meip and hence bit 11 of MIP 
        //have to set machine_external interrupt ----> external interrupt_pending
        #10 i_external_interrupt = 1;//mcause code 2 mcause_init_bit 0
        #10 i_external_interrupt = 0; 

        // Test software interrupt
        //sets mip_msip and is interrupt
        //mcause set to software_interrupt value 

        #10 i_software_interrupt = 1;
        #10 i_software_interrupt = 0;  


        #100 $finish;
    end

endmodule
