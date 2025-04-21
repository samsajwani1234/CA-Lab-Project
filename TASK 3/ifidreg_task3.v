module ifidreg_task3
  (
    input clk,
    input reset,
    input [31:0] instruction,
    input [63:0] A,
    input flush, 
    input IFIDWrite, 
    output reg [31:0] inst,
    output reg [63:0] a_out
  );
  always @(posedge clk)
    begin
      if (reset == 1'b1 || flush == 1'b1)
        begin
          inst = 32'b0;
          a_out = 64'b0;
        end
      else if (IFIDWrite == 1'b0)
        begin
          inst = instruction;
          a_out = A;
        end
    end
endmodule