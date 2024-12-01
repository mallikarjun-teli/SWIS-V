`define N 32
`define NOP 32'h00000013 // addi x0,x0,0
//`define SIM 

// Instruction Memory
`define INSTR_MEM_SIZE 20'h1000 //in bytes
`define PC_RESET 32'h00000000

// Data Memory
`define DATA_MEM_SIZE 20'h1000 //in bytes
`define DATA_START 32'h80002000


// Opcodes
`define R  7'b0110011
`define I 7'b0010011
`define LD 7'b0000011
`define S  7'b0100011
`define B 7'b1100011
`define J  7'b1101111
`define JR 7'b1100111
`define U  7'b0110111
`define UPC 7'b0010111
`define CSR 7'b1110011
`define FENCE 7'b0001111

// ALU Control Signals
`define ADD 4'b0000
`define SUB 4'b0001
`define AND 4'b0010
`define OR  4'b0011
`define XOR 4'b0100
`define SRL 4'b0101
`define SLL 4'b0110
`define SRA 4'b0111
`define BUF 4'b1000
`define SLT 4'b1001
`define SLTU 4'b1010
`define EQ 4'b1011
`define GE 4'b1100
`define GEU 4'b1101

//func3 for Load Instructions
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101

//func3 for Branch Instructions
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

//func3 for Arithmetic and Logical Instructions
`define ADDI 3'b000 
`define SUBI 3'b000 
`define SLLI 3'b001
`define SLTI 3'b010
`define SLTUI 3'b011
`define XORI 3'b100
`define SRLI 3'b101 
`define SRAI 3'b101 
`define ORI 3'b110
`define ANDI 3'b111


//func3 for CSR Instructions
`define CSRRW 3'b001
`define CSRRS 3'b010
`define CSRRC 3'b011
`define CSRRWI 3'b101
`define CSRRSI 3'b110
`define CSRRCI 3'b111

//func7 for CSR-ECALL/EBREAK
`define ECALL 7'b0000000
`define EBREAK 7'b0000001

//// M-mode CSRs ////
//Machine-info
`define MVENDORID 12'hF11
`define MARCHID 12'hF12
`define MHARTID 12'hF14
//Machine Trap Setup
`define MSTATUS 12'h300
`define MISA 12'h301
`define MIE 12'h304
`define MTVEC 12'h305
//Machine Trap Handling
`define MSCRATCH 12'h340
`define MEPC 12'h341
`define MCAUSE 12'h342
`define MTVAL 12'h343
`define MIP 12'h344

