#!/bin/bash

# 脚本名称: build_and_run.sh
# 功能: 编译并运行基于 mini-rv32ima.h 的 RISC-V 模拟器
# 使用 riscv-none-embed-* 工具链

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

# 编译 RISC-V 程序
echo "正在编译 RISC-V 程序..."
riscv-none-embed-gcc -o test.elf test.c
riscv-none-embed-objcopy -O binary test.elf test.bin

# 检查是否编译成功
if [ $? -ne 0 ]; then
    echo "错误: RISC-V 程序编译失败！"
    exit 1
fi

echo "RISC-V 程序编译成功，生成二进制文件: test.bin"

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