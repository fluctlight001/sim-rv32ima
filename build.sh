#!/bin/bash

# 检查是否提供了输入文件
if [ $# -eq 0 ]; then
    echo "用法: $0 <C文件>"
    exit 1
fi

# 获取输入文件名（不带扩展名）
input_file=$1
base_name=$(basename "$input_file" .c)

# 输出文件
elf_file="${base_name}.elf"
bin_file="${base_name}.bin"
dis_file="${base_name}.dis"

# 编译和链接
riscv-none-embed-gcc -march=rv32ima -mabi=ilp32 -nostdlib -T link.ld -O0 -o "$elf_file" "$input_file"

# 检查是否成功生成 ELF 文件
if [ -f "$elf_file" ]; then
    echo "编译成功: $elf_file 已生成"
else
    echo "编译失败"
    exit 1
fi

# 生成 BIN 文件
riscv-none-embed-objcopy -O binary "$elf_file" "$bin_file"

# 检查是否成功生成 BIN 文件
if [ -f "$bin_file" ]; then
    echo "BIN 文件生成成功: $bin_file 已生成"
else
    echo "BIN 文件生成失败"
    exit 1
fi

# 生成反汇编文件
riscv-none-embed-objdump -d "$elf_file" > "$dis_file"

# 检查是否成功生成反汇编文件
if [ -f "$dis_file" ]; then
    echo "反汇编文件生成成功: $dis_file 已生成"
else
    echo "反汇编文件生成失败"
    exit 1
fi

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
./rv32sim $bin_file simulator.log
if [ $? -ne 0 ]; then
    echo "错误: 运行模拟器时出现问题！"
    exit 1
fi

echo "模拟器运行完成。"