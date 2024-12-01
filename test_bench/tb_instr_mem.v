`include "../rtl/instr_mem.v"
`timescale 1ns / 1ps

module tb_instr_mem;

  // Signals
  reg clk;
  reg rst_n;
  reg [31:0] i_addr;
  reg i_stb;
  wire o_ack;
  wire [31:0] o_data;

  // Instantiate the module under test
  instr_mem dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_addr(i_addr),
    .i_stb(i_stb),
    .o_ack(o_ack),
    .o_data(o_data)
  );
  integer i;
  // Clock generation
  always #5 clk = ~clk;

  // Test case
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_instr_mem);

    // Initialize inputs
    clk = 0;
    rst_n = 0;
    i_addr = 0;
    i_stb = 0;

    // Reset
    #10 rst_n = 1;

    // Request for instruction at address 0x04 (4 bytes aligned)
    i_addr = 0;
    i_stb = 1;
    for (i=0; i<24; i++)
      begin
      #10 
      i_addr = i_addr + 32'd4;
      end  


    // Finish simulation
    #10 $finish;
  end

endmodule
