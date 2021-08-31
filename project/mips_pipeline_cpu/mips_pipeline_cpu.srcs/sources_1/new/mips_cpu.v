`timescale 1ns / 1ps
`include "defines.vh"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/28 10:09:24
// Design Name: 
// Module Name: mips_cpu
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


module mips_cpu(
    input   wire    clk,
    input   wire    rst,

    input   wire[`RegBus]   rom_rdata_i,
    input   wire[`RegBus]   ram_data_i, 
    output  wire[`RegBus]   rom_raddr_o,
    output  wire            rom_re_o,
    output  wire[`RegBus]    ram_addr_o,
    output  wire            ram_we_o,
    output  wire[`RegBus]    ram_data_o
    );

    // 连接 PC 模块和 ID 模块
    wire[`RegBus]       pc;
    wire                branch_flag;
    wire[`RegBus]       branch_target;

    // 连接 ID 模块和 Regfile 模块
    wire                reg_re1;
    wire                reg_re2;
    wire[`RegBus]       reg_rdata1;
    wire[`RegBus]       reg_rdata2;
    wire[`RegAddrBus]   reg_raddr1;
    wire[`RegAddrBus]   reg_raddr2;

    // 连接 ID 模块和 EX 模块
    wire[`AluSelBus]    alu_sel;
    wire[`RegBus]       alu_opnd1;
    wire[`RegBus]       alu_opnd2;
    wire                reg_we;
    wire[`RegAddrBus]   reg_waddr;
    wire[`RegBus]       id_ex_inst;
    
    // 连接 EX 模块和 MEM 模块
    wire                ex_we;
    wire[`RegAddrBus]   ex_waddr;
    wire[`RegBus]       ex_wdata;
    wire[`AluSelBus]    ex_alu_sel;
    wire[`RegBus]       ex_ram_addr;
    wire[`RegBus]       ex_reg_rt;

    // 连接 MEM 模块和 WB 模块
    wire                mem_we;
    wire[`RegAddrBus]   mem_waddr;
    wire[`RegBus]       mem_wdata;

    // 连接 WB 模块和 Regfile 模块
    wire                wb_we;
    wire[`RegAddrBus]   wb_waddr;
    wire[`RegBus]       wb_wdata;

    // 实例化 PC
    pc pc_real(
        .clk(clk),
        .rst(rst),
        // 来自 ID 模块的分支转移信息
        .branch_flag_i(branch_flag),
        .branch_target_i(branch_target),
        // 输出到指令存储器 ROM 的信息
        .pc_reg(pc),
        .ce(rom_re_o)
    );

    assign rom_raddr_o = pc;

    // 实例化 ID
    id id_real(
        .rst(rst),  

        // 来自 PC 模块的输入
        .inst_i(rom_rdata_i),
        .pc_i(pc),

        // 输出到 PC 模块的转移信息
        .branch_flag_o(branch_flag),
        .branch_target_o(branch_target),

        // 来自 Regfile 模块的输入
        .reg_rdata1_i(reg_rdata1),
        .reg_rdata2_i(reg_rdata2),

        // 输出到 Regfile 模块的信息
        .reg_re1_o(reg_re1),
        .reg_re2_o(reg_re2),
        .reg_raddr1_o(reg_raddr1),
        .reg_raddr2_o(reg_raddr2),

        // 输出到 EX 模块的信息
        .alu_sel_o(alu_sel),
        .alu_opnd1_o(alu_opnd1),
        .alu_opnd2_o(alu_opnd2),
        .reg_waddr_o(reg_waddr),
        .reg_we_o(reg_we),
        .inst_o(id_ex_inst)
    );

    // 实例化 Regfile
    regfile regfile_real(
        .clk(clk),
        .rst(rst),

        // 从 WB 模块传来信息
        .we_i(wb_we),
        .waddr_i(wb_waddr),
        .wdata_i(wb_wdata),

        // 从 ID 模块传来的信息
        .re1_i(reg_re1),
        .re2_i(reg_re2),
        .raddr1_i(reg_raddr1), 
        .raddr2_i(reg_raddr2),

        // 输出到 ID 模块的信息
        .rdata1_o(reg_rdata1),
        .rdata2_o(reg_rdata2)
    );

    // 实例化 EX 模块
    ex ex_real(
        .rst(rst),

        // 从 ID 模块传来的信息
        .inst_i(id_ex_inst),
        .alu_sel_i(alu_sel),
        .alu_opnd1_i(alu_opnd1),
        .alu_opnd2_i(alu_opnd2),
        .reg_waddr_i(reg_waddr),
        .reg_we_i(reg_we),

        // 输出到 MEM 模块的信息
        .reg_waddr_o(ex_waddr),
        .reg_we_o(ex_we),
        .reg_wdata_o(ex_wdata),
        .alu_sel_o(ex_alu_sel),
        .ram_addr_o(ex_ram_addr),
        .reg_rt_o(ex_reg_rt)
    );

    // 实例化 MEM 模块
    mem mem_real(
        .rst(rst),

        // 从 EX 模块传来的信息
        .ex_waddr_i(ex_waddr),
        .ex_we_i(ex_we),
        .ex_wdata_i(ex_wdata),
        .ex_alu_sel_i(ex_alu_sel),
        .ex_ram_addr_i(ex_ram_addr),
        .ex_reg_rt_i(ex_reg_rt),

        // 从数据存储器传来的信号
        .ram_data_i(ram_data_i),
        
        // 输出到 WB 模块的信息
        .mem_waddr_o(mem_waddr),
        .mem_we_o(mem_we),
        .mem_wdata_o(mem_wdata),

        // 输出到数据存储器的信号
        .mem_ram_addr_o(ram_addr_o),
        .mem_ram_we_o(ram_we_o),
        .mem_ram_data_o(ram_data_o)
    );

    // 实例化 WB 模块
    wb wb_real(
        .rst(rst),

        // 从 MEM 模块传来的信息
        .mem_waddr_i(mem_waddr),
        .mem_we_i(mem_we),
        .mem_wdata_i(mem_wdata),

        // 输出到 Regfile 模块的信息
        .wb_waddr_o(wb_waddr),
        .wb_we_o(wb_we),
        .wb_wdata_o(wb_wdata)
    );
        
endmodule
