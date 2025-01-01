#!/bin/bash

# 编译 RISC-V 程序
echo "正在编译 RISC-V 程序..."
riscv-none-embed-gcc -march=rv32ima -mabi=ilp32 -nostdlib -T link.ld -O0 -o test.elf test.c
if [ $? -ne 0 ]; then
    echo "错误: RISC-V 程序编译失败！"
    exit 1
fi

echo "RISC-V 程序编译成功，生成二进制文件: test.bin"

# 生成反汇编文件
echo "正在生成反汇编文件..."
riscv-none-embed-objdump -D test.elf > test.dis
if [ $? -ne 0 ]; then
    echo "错误: 生成反汇编文件失败！"
    exit 1
fi

echo "反汇编文件生成成功，保存为: test.dis"

# 移除 .comment 部分
echo "正在移除 .comment 部分..."
riscv-none-embed-objcopy --remove-section=.comment test.elf test_no_comment.elf
riscv-none-embed-objcopy -O binary test_no_comment.elf test.bin
riscv-none-embed-objdump -D test_no_comment.elf > test.dis

echo "已移除 .comment 部分，重新生成二进制文件和反汇编文件。"

# 编译模拟器
echo "正在编译模拟器..."
gcc -o rv32sim main.c
if [ $? -ne 0 ]; then
    echo "错误: 模拟器编译失败！"
    exit 1
fi

echo "模拟器编译成功，生成可执行文件: rv32sim"

# 运行模拟器
echo "正在运行模拟器..."
./rv32sim test.bin
if [ $? -ne 0 ]; then
    echo "错误: 运行模拟器时出现问题！"
    exit 1
fi

echo "模拟器运行完成。"