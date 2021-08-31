# Mips Pipeline CPU

## 设计目标
本实验设计实现了基于 MIPS32 指令集架构的处理器，设计的 CPU 具有以下特点：

1. 采用数据、指令存储器接口分开的哈佛结构；
2. 采用五级流水线结构，包含：取指、译码、执行、访存、写回
3. 包含 16 条基本 MIPS 指令

## 实验环境

* 硬件描述语言：Verilog HDL
* 仿真环境：Vivado 2019.2

## 实验步骤
参考 《自己动手写CPU》中 OpenMIPS 的设计，各模块如下图所示
![image-20210825131313737](https://i.loli.net/2021/08/27/xdPofU3NGpuasy7.png)

