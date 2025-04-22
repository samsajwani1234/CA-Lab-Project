`timescale 1ns / 1ps

module tb_hazard_detection_unit;

  // Inputs
  reg Memread;
  reg [31:0] inst;
  reg [4:0] Rd;
  // Output
  wire stall;

  // Instantiate the unit under test
  hazard_detection_unit UUT (
    .Memread(Memread),
    .inst(inst),
    .Rd(Rd),
    .stall(stall)
  );

  initial begin
    $display("Time | Memread |   inst[19:15]   inst[24:20]   Rd  | stall");
    $display("--------------------------------------------------------");
    // test vectors:
    // inst[19:15]=5, inst[24:20]=7
    inst = 32'b0;
    inst[19:15] = 5;
    inst[24:20] = 7;

    // 1) Memread=0 -> no stall
    Memread = 0; Rd = 5; #10;
    $display("%4dns |   %b     |      %0d           %0d      %0d |   %b",
             $time, Memread, inst[19:15], inst[24:20], Rd, stall);

    // 2) Memread=1, Rd matches inst[19:15]
    Memread = 1; Rd = 5; #10;
    $display("%4dns |   %b     |      %0d           %0d      %0d |   %b",
             $time, Memread, inst[19:15], inst[24:20], Rd, stall);

    // 3) Memread=1, Rd matches inst[24:20]
    Memread = 1; Rd = 7; #10;
    $display("%4dns |   %b     |      %0d           %0d      %0d |   %b",
             $time, Memread, inst[19:15], inst[24:20], Rd, stall);

    // 4) Memread=1, Rd matches neither
    Memread = 1; Rd = 3; #10;
    $display("%4dns |   %b     |      %0d           %0d      %0d |   %b",
             $time, Memread, inst[19:15], inst[24:20], Rd, stall);

    $finish;
  end

endmodule

