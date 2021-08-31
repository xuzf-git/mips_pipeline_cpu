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

    // ���� PC ģ��� ID ģ��
    wire[`RegBus]       pc;
    wire                branch_flag;
    wire[`RegBus]       branch_target;

    // ���� ID ģ��� Regfile ģ��
    wire                reg_re1;
    wire                reg_re2;
    wire[`RegBus]       reg_rdata1;
    wire[`RegBus]       reg_rdata2;
    wire[`RegAddrBus]   reg_raddr1;
    wire[`RegAddrBus]   reg_raddr2;

    // ���� ID ģ��� EX ģ��
    wire[`AluSelBus]    alu_sel;
    wire[`RegBus]       alu_opnd1;
    wire[`RegBus]       alu_opnd2;
    wire                reg_we;
    wire[`RegAddrBus]   reg_waddr;
    wire[`RegBus]       id_ex_inst;
    
    // ���� EX ģ��� MEM ģ��
    wire                ex_we;
    wire[`RegAddrBus]   ex_waddr;
    wire[`RegBus]       ex_wdata;
    wire[`AluSelBus]    ex_alu_sel;
    wire[`RegBus]       ex_ram_addr;
    wire[`RegBus]       ex_reg_rt;

    // ���� MEM ģ��� WB ģ��
    wire                mem_we;
    wire[`RegAddrBus]   mem_waddr;
    wire[`RegBus]       mem_wdata;

    // ���� WB ģ��� Regfile ģ��
    wire                wb_we;
    wire[`RegAddrBus]   wb_waddr;
    wire[`RegBus]       wb_wdata;

    // ʵ���� PC
    pc pc_real(
        .clk(clk),
        .rst(rst),
        // ���� ID ģ��ķ�֧ת����Ϣ
        .branch_flag_i(branch_flag),
        .branch_target_i(branch_target),
        // �����ָ��洢�� ROM ����Ϣ
        .pc_reg(pc),
        .ce(rom_re_o)
    );

    assign rom_raddr_o = pc;

    // ʵ���� ID
    id id_real(
        .rst(rst),  

        // ���� PC ģ�������
        .inst_i(rom_rdata_i),
        .pc_i(pc),

        // ����� PC ģ���ת����Ϣ
        .branch_flag_o(branch_flag),
        .branch_target_o(branch_target),

        // ���� Regfile ģ�������
        .reg_rdata1_i(reg_rdata1),
        .reg_rdata2_i(reg_rdata2),

        // ����� Regfile ģ�����Ϣ
        .reg_re1_o(reg_re1),
        .reg_re2_o(reg_re2),
        .reg_raddr1_o(reg_raddr1),
        .reg_raddr2_o(reg_raddr2),

        // ����� EX ģ�����Ϣ
        .alu_sel_o(alu_sel),
        .alu_opnd1_o(alu_opnd1),
        .alu_opnd2_o(alu_opnd2),
        .reg_waddr_o(reg_waddr),
        .reg_we_o(reg_we),
        .inst_o(id_ex_inst)
    );

    // ʵ���� Regfile
    regfile regfile_real(
        .clk(clk),
        .rst(rst),

        // �� WB ģ�鴫����Ϣ
        .we_i(wb_we),
        .waddr_i(wb_waddr),
        .wdata_i(wb_wdata),

        // �� ID ģ�鴫������Ϣ
        .re1_i(reg_re1),
        .re2_i(reg_re2),
        .raddr1_i(reg_raddr1), 
        .raddr2_i(reg_raddr2),

        // ����� ID ģ�����Ϣ
        .rdata1_o(reg_rdata1),
        .rdata2_o(reg_rdata2)
    );

    // ʵ���� EX ģ��
    ex ex_real(
        .rst(rst),

        // �� ID ģ�鴫������Ϣ
        .inst_i(id_ex_inst),
        .alu_sel_i(alu_sel),
        .alu_opnd1_i(alu_opnd1),
        .alu_opnd2_i(alu_opnd2),
        .reg_waddr_i(reg_waddr),
        .reg_we_i(reg_we),

        // ����� MEM ģ�����Ϣ
        .reg_waddr_o(ex_waddr),
        .reg_we_o(ex_we),
        .reg_wdata_o(ex_wdata),
        .alu_sel_o(ex_alu_sel),
        .ram_addr_o(ex_ram_addr),
        .reg_rt_o(ex_reg_rt)
    );

    // ʵ���� MEM ģ��
    mem mem_real(
        .rst(rst),

        // �� EX ģ�鴫������Ϣ
        .ex_waddr_i(ex_waddr),
        .ex_we_i(ex_we),
        .ex_wdata_i(ex_wdata),
        .ex_alu_sel_i(ex_alu_sel),
        .ex_ram_addr_i(ex_ram_addr),
        .ex_reg_rt_i(ex_reg_rt),

        // �����ݴ洢���������ź�
        .ram_data_i(ram_data_i),
        
        // ����� WB ģ�����Ϣ
        .mem_waddr_o(mem_waddr),
        .mem_we_o(mem_we),
        .mem_wdata_o(mem_wdata),

        // ��������ݴ洢�����ź�
        .mem_ram_addr_o(ram_addr_o),
        .mem_ram_we_o(ram_we_o),
        .mem_ram_data_o(ram_data_o)
    );

    // ʵ���� WB ģ��
    wb wb_real(
        .rst(rst),

        // �� MEM ģ�鴫������Ϣ
        .mem_waddr_i(mem_waddr),
        .mem_we_i(mem_we),
        .mem_wdata_i(mem_wdata),

        // ����� Regfile ģ�����Ϣ
        .wb_waddr_o(wb_waddr),
        .wb_we_o(wb_we),
        .wb_wdata_o(wb_wdata)
    );
        
endmodule
