`include "if.v"

module tbiF();
reg clk;
reg rst_n;
wire [31:0] o_InstrD;
wire [31:0] o_PcD;

If dut(
    .clk(clk),
    .rst_n(rst_n),
    .o_InstrD(o_InstrD),
    .o_PcD(o_PcD)
);

  always #5 clk = ~clk;

initial 
begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tbiF);
    clk = 0;
    rst_n = 0;

    #10 rst_n = 1;
    #100
    $finish;
end
endmodule