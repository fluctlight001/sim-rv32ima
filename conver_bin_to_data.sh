#!/bin/bash

# 输入和输出目录
input_dir="test"
output_dir="data"

# 创建输出目录（如果不存在）
mkdir -p "$output_dir"

# 遍历输入目录中的所有 .bin 文件
for bin_file in "$input_dir"/*.bin; do
    # 获取文件名（不含扩展名）
    base_name=$(basename "$bin_file" .bin)
    # 定义输出文件路径
    data_file="$output_dir/$base_name.data"

    # 清空或创建输出文件
    > "$data_file"

    # 读取 .bin 文件并转换为 .data 文件（大端序）
    hexdump -v -e '1/4 "%08x" "\n"' "$bin_file" >> "$data_file"

    echo "Converted $bin_file to $data_file"
done

echo "Conversion completed!"