#!/bin/bash

# 输入文件夹路径
INPUT_DIR="test"
# 输出文件夹路径
OUTPUT_DIR="disasm"

# 创建输出文件夹
mkdir -p "$OUTPUT_DIR"

# 遍历输入文件夹中的所有文件
for elf_file in "$INPUT_DIR"/*.elf; do
    # 获取文件名（不含路径和扩展名）
    filename=$(basename "$elf_file" .elf)
    # 定义输出文件路径
    output_file="$OUTPUT_DIR/$filename.disasm"

    # 使用 objdump 反汇编 ELF 文件
    echo "Disassembling $elf_file -> $output_file"
    riscv-none-embed-objdump -d -m riscv "$elf_file" > "$output_file"

    # 检查是否成功
    if [ $? -eq 0 ]; then
        echo "Successfully disassembled $elf_file"
    else
        echo "Failed to disassemble $elf_file"
    fi
done

echo "All files processed. Output saved to $OUTPUT_DIR"