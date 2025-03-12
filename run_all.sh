#!/bin/bash

gcc -o riscv_simulator main.c # 编译riscv_simulator
# ./riscv_simulator test/dummy-riscv32-ni.bin  simulator.log # 单独运行某个bin文件
bash disassemble_riscv.sh # 生成反汇编文件，产物在disasm/
bash conver_bin_to_data.sh # 生成data文件（16进制文件）用于vivado仿真
bash golden_trace.sh # 生成trace文件，用于vivado仿真时比对结果
bash golden_trace/add_line_count.sh

echo "all finish"