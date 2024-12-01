`timescale 1ns / 1ps
`default_nettype none
`include "../rtl/parameters.vh"

module branch_decision(
input wire [31:0] i_read_data1,
input wire [31:0] i_read_data2,
input wire [2:0] i_Func3,
output reg o_Branch
);
   
always @(*)
begin
    case(i_Func3)
        `BEQ:begin
                 if(i_read_data1 == i_read_data2) 	
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
             end
        `BNE:begin
                 if(i_read_data1 != i_read_data2)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
            end
        `BLT:begin
                 if((i_read_data1[31] ^ i_read_data2[31])? i_read_data2[31] : ($signed(i_read_data1) <= $signed(i_read_data2)))
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
            end
        `BGE:begin
                 if((i_read_data1[31] ^ i_read_data2[31])? i_read_data1[31] : ($signed(i_read_data1) >= $signed(i_read_data1)))
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
            end
        `BLTU:begin
                 if(i_read_data1 <= i_read_data2)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
             end
        `BGEU:begin
                 if(i_read_data1 >= i_read_data2)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
             end
        default:
                    o_Branch = 1'b0;
    endcase
end

endmodule
