`timescale 1ns / 1ps

module Mux
(
input [63:0] a,
input [63:0] b,
input s,
output reg [63:0] data_out
);

always @ (a, b, s)
begin
if (!s)
data_out = a;
else
data_out = b;
end
endmodule

