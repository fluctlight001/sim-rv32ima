#!/bin/bash

# 输入文件夹路径
INPUT_DIR="test"
# 输出文件夹路径
OUTPUT_DIR="golden_trace"

# 创建输出文件夹
mkdir -p "$OUTPUT_DIR"

# 遍历输入文件夹中的所有文件
for bin_file in "$INPUT_DIR"/*.bin; do
    # 获取文件名（不含路径和扩展名）
    filename=$(basename "$bin_file" .bin)
    # 定义输出文件路径
    output_file="$OUTPUT_DIR/$filename.ans"

    # 使用 objdump 反汇编 ELF 文件
    echo "generate $bin_file -> $output_file"
    ./riscv_simulator "$bin_file" simulator.log > "$output_file"

    # 检查是否成功
    if [ $? -eq 0 ]; then
        echo "Successfully generate $bin_file"
    else
        echo "Failed to generate $bin_file"
    fi
done

echo "All files processed. Output saved to $OUTPUT_DIR"