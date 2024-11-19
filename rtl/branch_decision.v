`timescale 1ns / 1ps
`default_nettype none
`include "parameters.vh"

module branch_decision(
input wire [31:0] i_result,
input wire [2:0] i_func3,
output reg o_branch
);
   
always @(*)
begin
    case(i_func3)
        `BEQ:begin
                 if(i_result[0] == 1'd1) 	
                    o_branch = 1'b1;
                 else
                    o_branch = 1'b0;
             end
        `BNE:begin
                 if(i_result[0] == 1'd0)
                    o_branch = 1'b1;
                 else
                    o_branch = 1'b0;
            end
        `BLT:begin
                 if(i_result[0] == 1'd0)
                    o_branch = 1'b1;
                 else
                    o_branch = 1'b0;
            end
        `BGE:begin
                 if(i_result[0] == 1'd1)
                    o_branch = 1'b1;
                 else
                    o_branch = 1'b0;
            end
        `BLTU:begin
                 if(i_result[0] == 1'd0)
                    o_branch = 1'b1;
                 else
                    o_branch = 1'b0;
             end
        `BGEU:begin
                 if(i_result[0] == 1'd1)
                    o_branch = 1'b1;
                 else
                    o_branch = 1'b0;
             end
        default:
                    o_branch = 1'b0;
    endcase
end

endmodule
