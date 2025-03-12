#!/bin/bash

# 定义文件夹路径和日志文件路径
input_dir="./data"  # 替换为你的文件夹路径
log_file="unit_tests.log"  # 日志文件名

# 清空日志文件（如果存在）
> "$log_file"

# 遍历文件夹中的所有 .data 文件
for file in "$input_dir"/*-riscv32-ni.data; do
    # 提取文件名中 -riscv32-ni.data 之前的部分
    filename=$(basename "$file" "-riscv32-ni.data")
    
    # 格式化输出并追加到日志文件
    echo "unit_test(\"$filename\");" >> "$log_file"
done

echo "日志文件已生成: $log_file"