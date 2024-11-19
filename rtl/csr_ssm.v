`timescale 1ns / 1ps
`define LOAD    7'b0000011
`define STORE   7'b0100011
`define BRANCH  7'b1100011
`define JAL     7'b1101111
`define JALR    7'b1100111
`define SYSTEM  7'b1110011
`define OPCODE_WIDTH 4'd8
module csr_ssm #(parameter OPCODE_WIDTH = 8,parameter TRAP_ADDRESS = 0)

 (
    input wire i_clk, i_rst_n,
    // Interrupts
    input wire i_external_interrupt, //interrupt from external source
    input wire i_software_interrupt, //interrupt from software (inter-processor interrupt)
    
    /// Exceptions ///
    input wire i_is_inst_illegal, //illegal instruction
    input wire i_is_ecall, //ecall instruction
    input wire i_is_ebreak, //ebreak instruction
    input wire i_is_mret, //mret (return from trap) instruction
    /// Instruction/Load/Store Misaligned Exception///
    input wire[OPCODE_WIDTH-1:0] i_opcode, //opcode types
    input wire[31:0] i_y, //y value from ALU (address used in load/store/jump/branch)
    /// CSR instruction ///
    input wire[2:0] i_funct3, // CSR instruction operation
    input wire[11:0] i_csr_index, // immediate value from decoder 
    //i_csr_index is like mvendorid or marchid....tells which cse we are accessing
    input wire[31:0] i_imm, //unsigned immediate for immediate type of CSR instruction (new value to be stored to CSR)
    //i_imm stores the immediate value to be writen to CSR incase CSRRWI/CSRRSI/CSRRCI are used
    input wire[31:0] i_rs1, //Source register 1 value (new value to be stored to CSR)
    //i_rs1 value to be written to csr
    output reg[31:0] o_csr_out, //CSR value to be loaded to basereg
    //o_csr_out---> value read from csr
    // Trap-Handler 
    input wire[31:0] i_pc, //Program Counter 
    input wire writeback_change_pc, //high if writeback will issue change_pc (which will override this stage)
    output reg[31:0] o_return_address, //mepc CSR
    output reg[31:0] o_trap_address, //mtvec CSR
    output reg o_go_to_trap_q, //high before going to trap (if exception/interrupt detected)
    output reg o_return_from_trap_q //high before returning from trap (via mret)
    );


            //CSR operation type
    localparam CSRRW = 3'b001,
               CSRRS = 3'b010,
               CSRRC = 3'b011,
               CSRRWI = 3'b101,
               CSRRSI = 3'b110,
               CSRRCI = 3'b111;

     localparam MVENDORID = 12'hF11,  
               MARCHID = 12'hF12,
               MIMPID = 12'hF13,
               MHARTID = 12'hF14,
               //machine trap setup
               MSTATUS = 12'h300, 
               MISA = 12'h301,
               MIE = 12'h304,
               MTVEC = 12'h305,
               //machine trap handling
               MSCRATCH = 12'h340, 
               MEPC = 12'h341,
               MCAUSE = 12'h342,
               MTVAL = 12'h343,
               MIP = 12'h344;

                   //mcause codes --------->written to lower 4 bits of mcause
    localparam MACHINE_SOFTWARE_INTERRUPT =3,

               MACHINE_EXTERNAL_INTERRUPT = 11,
               INSTRUCTION_ADDRESS_MISALIGNED = 0,
               ILLEGAL_INSTRUCTION = 2,
               EBREAK = 3,
               LOAD_ADDRESS_MISALIGNED = 4,
               STORE_ADDRESS_MISALIGNED = 6,
               ECALL = 11;

// determines if the instruction is a load store or branch instruction
// the following declarations are equivalent to
// wire opcode_store = (i_opcode == `STORE); ------> store,load, branch are some bit patterns
// define LOAD    7'b0000011
wire opcode_branch,opcode_jal,opcode_jalr,opcode_load,opcode_store,opcode_system;
    assign opcode_store=i_opcode[`STORE];
    assign opcode_load=i_opcode[`LOAD];
    assign opcode_branch=i_opcode[`BRANCH];
    assign opcode_jal=i_opcode[`JAL];
    assign opcode_jalr=i_opcode[`JALR];
    assign opcode_system= (i_opcode == `SYSTEM);


    reg[31:0] csr_in; //value to be stored to CSR
    reg[31:0] csr_data; //value at current CSR address
    wire csr_enable = opcode_system && i_funct3!=0 && !writeback_change_pc; //csr read/write operation is enabled only at this conditions
    reg[1:0] new_pc = 0; //last two bits of i_pc that will be used in taken branch and jumps
    reg go_to_trap; //high before going to trap (if exception/interrupt detected)
    reg return_from_trap; //high before returning from trap (via mret)
    reg is_load_addr_misaligned; 
    reg is_store_addr_misaligned;
    reg is_inst_addr_misaligned;
    reg external_interrupt_pending; 
    reg software_interrupt_pending;
    reg is_interrupt;
    reg is_exception;
    reg is_trap;
    reg update_enable;


        // CSR register bits
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



        always @* begin
        is_load_addr_misaligned = 0;
        is_store_addr_misaligned = 0;
        is_inst_addr_misaligned = 0;
        new_pc = 0;
        
        // Misaligned Load/Store Address
        if(i_funct3[1:0] == 2'b01) begin //halfword load/store
            is_load_addr_misaligned = opcode_load? i_y[0] : 0;
            is_store_addr_misaligned = opcode_store? i_y[0] : 0;
        end
        if(i_funct3[1:0] == 2'b10) begin //word load/store
            is_load_addr_misaligned = opcode_load? i_y[1:0]!=2'b00 : 0;
            is_store_addr_misaligned = opcode_store? i_y[1:0]!=2'b00 : 0;
        end
        
        // Misaligned Instruction Address
        /* Volume 1 pg. 15: Instructions are 32 bits in length and must be aligned on a four-byte boundary in memory.
        An instruction-address-misaligned exception is generated on a taken branch or unconditional jump
        if the target address is not four-byte aligned. This exception is reported on the branch or jump
        instruction, not on the target instruction. No instruction-address-misaligned exception is generated
        for a conditional branch that is not taken. */
        if((opcode_branch && i_y[0]) || opcode_jal || opcode_jalr) begin // branch or jump to new instruction
            new_pc = i_pc[1:0] + i_csr_index[1:0];
            if(opcode_jalr) new_pc = i_rs1[1:0] +  i_csr_index[1:0];
            is_inst_addr_misaligned = (new_pc == 2'b00)? 1'b0:1'b1; //i_pc (instruction address) must always be four bytes aligned
        end
        
    end


    //Control logic for writing to CSR

     always @(posedge i_clk,negedge i_rst_n)
      begin
        if(!i_rst_n)
         begin
            o_go_to_trap_q <= 0;
            o_return_from_trap_q <= 0;        
            mstatus_mie <= 0;
            mstatus_mpie <= 0;
            mstatus_mpp <= 2'b11;
            mie_meie <= 0;
          
            mie_msie <= 0;
            mtvec_base <= TRAP_ADDRESS[31:2];
            mtvec_mode <= TRAP_ADDRESS[1:0];
            mscratch <= 0;
            mepc <= 0;
            mcause_intbit <= 0;
            mcause_code <= 0;
            mtval <= 0;
            mip_meip <= 0;
            mip_msip <= 0;
        end

    else   //CSR CONTROL LOGIC
        begin


        //MSTATUS (controls hart's current operating state (mie and mpie are the only configurable bits))
        if(i_csr_index == MSTATUS && csr_enable) 
            begin 
                mstatus_mie <= csr_in[3];
                mstatus_mpie <= csr_in[7];
                //mstatus_mpp <= csr_in[12:11];
            end  

            //MIE (interrupt enable bits)
        if(i_csr_index == MIE && csr_enable)
            begin   
                mie_msie <= csr_in[3]; 
                mie_meie <= csr_in[11]; 
            end 

            //MTVEC (trap vector configuration (base+mode))
        if(i_csr_index == MTVEC && csr_enable)
             begin
                mtvec_base <= csr_in[31:2];
                mtvec_mode <= csr_in[1:0]; 
            end

            //MSCRATCH (dedicated for use by machine code)   
        if(i_csr_index == MSCRATCH && csr_enable) 
            begin
                mscratch <= csr_in;
            end

            //MEPC (address of interrupted instruction)
        if(i_csr_index == MEPC && csr_enable) 
            begin 
                mepc <= {csr_in[31:2],2'b00};
            end
            /* Volume 2 pg. 38: When a trap is taken into M-mode, mepc is written with the virtual address of the 
             instruction that was interrupted or that encountered the exception */
        if(go_to_trap && !o_go_to_trap_q)
         mepc <= i_pc;
            
            //MCAUSE (indicates cause of trap(either interrupt or exception))
        if(i_csr_index == MCAUSE && csr_enable) 
            begin
               mcause_intbit <= csr_in[31];
               mcause_code <= csr_in[3:0];         
            end

 /* Volume 2 pg. 38: When a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap */
// Interrupts have priority (external first, then s/w, then timer---[2] sec 3.1.9), then synchronous traps.
            if(go_to_trap && !o_go_to_trap_q)
                begin 
                    if(external_interrupt_pending)
                        begin 
                            mcause_code <= MACHINE_EXTERNAL_INTERRUPT; 
                            mcause_intbit <= 1;
                        end
                    else if(software_interrupt_pending) 
                        begin
                            mcause_code <= MACHINE_SOFTWARE_INTERRUPT; 
                            mcause_intbit <= 1;
                        end

                    else if(i_is_inst_illegal) 
                        begin
                            mcause_code <= ILLEGAL_INSTRUCTION;
                            mcause_intbit <= 0 ;
                        end
                    else if(is_inst_addr_misaligned) 
                        begin
                            mcause_code <= INSTRUCTION_ADDRESS_MISALIGNED;
                            mcause_intbit <= 0;
                        end
                    else if(i_is_ecall)
                         begin 
                            mcause_code <= ECALL;
                            mcause_intbit <= 0;
                        end
                    else if(i_is_ebreak) 
                        begin
                            mcause_code <= EBREAK;
                            mcause_intbit <= 0;
                        end
                    else if(is_load_addr_misaligned) 
                        begin
                            mcause_code <= LOAD_ADDRESS_MISALIGNED;
                            mcause_intbit <= 0;
                        end
                    else if(is_store_addr_misaligned)
                        begin
                            mcause_code <= STORE_ADDRESS_MISALIGNED;
                            mcause_intbit <= 0;
                        end
                end   

             //MTVAL (exception-specific information to assist software in handling trap)
            if(i_csr_index == MTVAL && csr_enable) begin
                mtval <= csr_in;
            end
            /*If mtval is written with a nonzero value when a breakpoint, address-misaligned, access-fault, or
            page-fault exception occurs on an instruction fetch, load, or store, then mtval will contain the
            faulting virtual address.*/
            if(go_to_trap && !o_go_to_trap_q)
             begin
                if(is_load_addr_misaligned || is_store_addr_misaligned)
                     mtval <= i_y;
             end  

            //MIP (pending interrupts)       
            mip_msip <= i_software_interrupt;
            mip_meip <= i_external_interrupt;            
            
           update_enable = (go_to_trap || return_from_trap || csr_enable);

            if(update_enable) 
                begin
                    o_go_to_trap_q <= go_to_trap;
                    o_return_from_trap_q <= return_from_trap;
                    o_return_address <= mepc;
                    if(mtvec_mode[1] && is_interrupt) 
                        o_trap_address <= {mtvec_base, 2'b00} + {28'b0, mcause_code << 2};
                    else 
                        o_trap_address <= {mtvec_base, 2'b00};
                    
                    o_csr_out <= csr_data;
                end 
            
            else 
                begin
                o_go_to_trap_q <= 0;
                o_return_from_trap_q <= 0;
                 end
    end

end


     always @*
      begin
        /************************************************** control logic for trap detection **************************************************/
        external_interrupt_pending = 0;
        software_interrupt_pending = 0;
        is_interrupt = 0;
        is_exception = 0;
        is_trap = 0;
        go_to_trap = 0;
        return_from_trap = 0;
        
        if(i_rst_n) begin
             external_interrupt_pending =  mstatus_mie && mie_meie && (mip_meip); //machine_interrupt_enable + machine_external_interrupt_enable + machine_external_interrupt_pending must all be high
             software_interrupt_pending = mstatus_mie && mie_msie && mip_msip;  //machine_interrupt_enable + machine_software_interrupt_enable + machine_software_interrupt_pending must all be high
             
             is_interrupt = external_interrupt_pending || software_interrupt_pending;
             is_exception = (i_is_inst_illegal || is_inst_addr_misaligned || i_is_ecall || i_is_ebreak || is_load_addr_misaligned || is_store_addr_misaligned) && !writeback_change_pc;
             is_trap = is_interrupt || is_exception;
             go_to_trap = is_trap; //a trap is taken, save i_pc, and go to trap address
             return_from_trap = i_is_mret; // return from trap, go back to saved i_pc
             
         end
         /*************************************************************************************************************************************/
         
         
        csr_data = 0;
        csr_in = 0;
        /************************************ specify csr_data (data CURRENTLY stored at the CSR) *********************************************/
        case(i_csr_index)
            //machine info
            MVENDORID: csr_data = 32'h0;  //MVENDORID (JEDEC manufacturer ID)
              MARCHID: csr_data = 32'h0; //MARCHID (open-source project architecture ID allocated by RISC-V International  ( https://github.com/riscv/riscv-isa-manual/blob/master/marchid.md ))
               MIMPID: csr_data = 32'h0; //MIMPID (version of the processor implementation (provided by author of source code))
              MHARTID: csr_data = 32'h0; //MHARTID (integer ID of the hart that is currently running the code (one hart must have an ID of zero))             
            
            //machine trap setup  
              MSTATUS: begin //MSTATUS (controls hart's current operating state (mie and mpie are the only configurable bits))
                        csr_data[3] = mstatus_mie;
                        csr_data[7] = mstatus_mpie;
                        csr_data[12:11] = mstatus_mpp; //MPP
                       end
                       
                 MISA: begin //MISA (control and monitor hart's current operating state)
                        csr_data[8] = 1'b1; //RV32I/64I/128I base ISA (ISA supported by the hart)
                        csr_data[31:30] = 2'b01; //Base 32
                       end
                       
                  MIE: begin //MIE (interrupt enable bits)
                        csr_data[3] = mie_msie;
                        
                        csr_data[11] = mie_meie;
                       end
                       
                MTVEC: begin //MTVEC (trap vector configuration (base+mode))
                        csr_data = {mtvec_base,mtvec_mode};
                       end
                       
            //machine trap handling
             MSCRATCH: begin //MSCRATCH (dedicated for use by machine code) 
                        csr_data = mscratch;
                       end
                       
                 MEPC: begin //MEPC (address of interrupted instruction)
                        csr_data = mepc; 
                       end
                       
               MCAUSE: begin //MCAUSE (indicates cause of trap(either interrupt or exception))
                        csr_data[31] = mcause_intbit; 
                        csr_data[3:0] = mcause_code;
                       end
                       
                MTVAL: begin //MTVAL (exception-specific information to assist software in handling trap)
                        csr_data = mtval;
                       end
                
                  MIP: begin //MIP (pending interrupts)
                        csr_data[3] = mip_msip;
                        csr_data[7] = mip_mtip;
                        csr_data[11] = mip_meip;
                       end
                       
  
              default: csr_data = 0;
        endcase
        /*****************************************************************************************************************************/
        
        
        
        /************************************ specify csr_in (data TO BE stored at the CSR ) *****************************************/
        // specify csr_in (data TO BE stored to CSR)
        case(i_funct3) //csr instruction type
            CSRRW: csr_in = i_rs1; //CSR read-write
            CSRRS: csr_in = csr_data | i_rs1; //CSR read-set
            CSRRC: csr_in = csr_data & (~i_rs1); //CSR read-clear
           CSRRWI: csr_in = i_imm; //csr read-write immediate
           CSRRSI: csr_in = csr_data | i_imm;  //csr read-set immediate
           CSRRCI: csr_in = csr_data & (~i_imm); //csr read-clear immediate
          default: csr_in = 0;
        endcase
        /*****************************************************************************************************************************/
   
   end
    
endmodule  
