import os
import struct

def bin_to_data(bin_file, data_file):
    """
    将 .bin 文件转换为 .data 文件
    """
    with open(bin_file, 'rb') as bf:
        with open(data_file, 'w') as df:
            while True:
                # 每次读取 4 字节（32 位）
                chunk = bf.read(4)
                if not chunk:
                    break
                # 如果读取的字节数不足 4 字节，填充 0
                if len(chunk) < 4:
                    chunk += b'\x00' * (4 - len(chunk))
                # 将 4 字节解析为 32 位整数
                value = struct.unpack('<I', chunk)[0]
                # 将整数转换为 8 位十六进制字符串
                data_line = f"{value:08x}"
                # 写入 .data 文件
                df.write(data_line + '\n')

def batch_convert_bin_to_data(input_dir, output_dir):
    """
    批量将 .bin 文件转换为 .data 文件
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for bin_file in os.listdir(input_dir):
        if bin_file.endswith('.bin'):
            bin_path = os.path.join(input_dir, bin_file)
            data_file = os.path.splitext(bin_file)[0] + '.data'
            data_path = os.path.join(output_dir, data_file)
            bin_to_data(bin_path, data_path)
            print(f"Converted {bin_path} to {data_path}")

if __name__ == "__main__":
    input_directory = "bin_files"  # 存放 .bin 文件的目录
    output_directory = "data_files"  # 存放 .data 文件的目录

    batch_convert_bin_to_data(input_directory, output_directory)