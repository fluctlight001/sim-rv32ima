#!/bin/bash

# 脚本名称: build_and_run.sh
# 功能: 编译并运行基于 mini-rv32ima.h 的 RISC-V 模拟器
# 模拟器使用 gcc 编译，RISC-V 程序使用 riscv-none-embed-* 工具链编译
# 移除 .comment 部分以确保二进制文件简洁

# 检查是否提供了源文件
if [ ! -f "mini-rv32ima.h" ]; then
    echo "错误: 未找到 mini-rv32ima.h 文件！"
    exit 1
fi

if [ ! -f "main.c" ]; then
    echo "错误: 未找到 main.c 文件！"
    exit 1
fi

# 检查是否安装了 gcc
if ! command -v gcc &> /dev/null; then
    echo "错误: 未找到 gcc 编译器！请先安装 gcc。"
    exit 1
fi

# 检查是否安装了 riscv-none-embed-gcc
if ! command -v riscv-none-embed-gcc &> /dev/null; then
    echo "错误: 未找到 riscv-none-embed-gcc 编译器！请先安装 riscv-none-embed 工具链。"
    exit 1
fi

# 检查是否安装了 riscv-none-embed-objdump
if ! command -v riscv-none-embed-objdump &> /dev/null; then
    echo "错误: 未找到 riscv-none-embed-objdump 工具！请确保 riscv-none-embed 工具链已安装。"
    exit 1
fi

# 编译 RISC-V 程序
echo "正在编译 RISC-V 程序..."
riscv-none-embed-gcc -march=rv32ima -mabi=ilp32 -nostdlib -T link.ld -o test.elf test.c
riscv-none-embed-objcopy -O binary test.elf test.bin

# 检查是否编译成功
if [ $? -ne 0 ]; then
    echo "错误: RISC-V 程序编译失败！"
    exit 1
fi

echo "RISC-V 程序编译成功，生成二进制文件: test.bin"

# 生成反汇编文件
echo "正在生成反汇编文件..."
riscv-none-embed-objdump -D test.elf > test.dis

# 检查是否生成成功
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

# 检查是否编译成功
if [ $? -ne 0 ]; then
    echo "错误: 模拟器编译失败！"
    exit 1
fi

echo "模拟器编译成功，生成可执行文件: rv32sim"

# 运行模拟器
echo "正在运行模拟器..."
./rv32sim test.bin

# 检查是否运行成功
if [ $? -ne 0 ]; then
    echo "错误: 运行模拟器时出现问题！"
    exit 1
fi

echo "模拟器运行完成。"