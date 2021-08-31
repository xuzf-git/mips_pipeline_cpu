`timescale 1ns / 1ps
// `include "single_cycle.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/28 22:13:54
// Design Name: 
// Module Name: testbench_sc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_single_cycle();

    reg CLOCK_50;
    reg rst;

    initial begin
        CLOCK_50 = 1'b0;
        rst = `RstEnable;
        #75 rst= `RstDisable;
        #1000 $finish;
    end

    always #10 CLOCK_50=~CLOCK_50;

    single_cycle single_cycle_real (
        .clk(CLOCK_50),
        .rst(rst)
    );
endmodule

