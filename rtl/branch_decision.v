`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module branch_decision(
input wire [31:0] i_Result,
input wire [2:0] i_Func3,
output reg o_Branch
);
   
always @(*)
begin
    case(i_Func3)
        `BEQ:begin
                 if(i_Result[0] == 1'd1) 	
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
             end
        `BNE:begin
                 if(i_Result[0] == 1'd0)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
            end
        `BLT:begin
                 if(i_Result[0] == 1'd0)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
            end
        `BGE:begin
                 if(i_Result[0] == 1'd1)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
            end
        `BLTU:begin
                 if(i_Result[0] == 1'd0)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
             end
        `BGEU:begin
                 if(i_Result[0] == 1'd1)
                    o_Branch = 1'b1;
                 else
                    o_Branch = 1'b0;
             end
        default:
                    o_Branch = 1'b0;
    endcase
end

endmodule
