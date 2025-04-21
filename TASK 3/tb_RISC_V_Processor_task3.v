`timescale 1ns / 1ps

module tb_RISC_V_processor_task3;

    reg clk;
    reg reset;

    wire [63:0] element1, element2, element3, element4;
    wire [63:0] element5, element6, element7, element8;

    RISC_V_Processor_task3 uut (
        .clk(clk),
        .reset(reset),
        .element1(element1),
        .element2(element2),
        .element3(element3),
        .element4(element4),
        .element5(element5),
        .element6(element6),
        .element7(element7),
        .element8(element8)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #20 reset = 0;
    end

endmodule

