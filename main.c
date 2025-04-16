#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define MINI_RV32_RAM_SIZE 1024 * 1024 // 定义RAM大小为1 MB
#define MINIRV32_IMPLEMENTATION
// 函数：将指令执行日志写入日志文件
void log_instruction(FILE* log_file, uint32_t pc, int write_reg, uint32_t reg_addr, uint32_t reg_value) {
    fprintf(log_file, "PC: 0x%08X, Write: %d, Reg: %u, Value: 0x%08X\n", pc, write_reg, reg_addr, reg_value);
}

#include "mini-rv32ima.h"

// 函数：读取二进制文件到内存中
uint8_t* read_binary_file(const char* filename, size_t* size) {
    FILE* file = fopen(filename, "rb"); // 以二进制模式打开文件
    if (!file) {
        perror("Failed to open file"); // 如果文件打开失败，输出错误信息
        return NULL;
    }

    fseek(file, 0, SEEK_END); // 将文件指针移动到文件末尾
    *size = ftell(file); // 获取文件大小
    fseek(file, 0, SEEK_SET); // 将文件指针移动回文件开头

    uint8_t* buffer = (uint8_t*)malloc(*size); // 分配内存以存储文件内容
    if (!buffer) {
        perror("Failed to allocate memory"); // 如果内存分配失败，输出错误信息
        fclose(file);
        return NULL;
    }

    fread(buffer, 1, *size, file); // 读取文件内容到缓冲区
    fclose(file); // 关闭文件
    return buffer; // 返回缓冲区指针
}


int main(int argc, char* argv[]) {
    if (argc != 3) { // 检查命令行参数数量是否正确
        fprintf(stderr, "Usage: %s <binary_file> <log_file>\n", argv[0]);
        return 1;
    }

    const char* binary_file = argv[1]; // 获取二进制文件名
    const char* log_file_name = argv[2]; // 获取日志文件名

    // 读取二进制文件
    size_t binary_size;
    uint8_t* binary_data = read_binary_file(binary_file, &binary_size);
    // printf("File size: %zu bytes\n", binary_size); // 输出文件大小
    if (!binary_data) {
        return 1;
    }

    // 为RISC-V状态和RAM分配内存
    struct MiniRV32IMAState state;
    uint8_t* ram = (uint8_t*)calloc(MINI_RV32_RAM_SIZE, 1); // 分配1 MB的RAM并初始化为0
    if (!ram) {
        perror("Failed to allocate RAM"); // 如果RAM分配失败，输出错误信息
        free(binary_data);
        return 1;
    }

    // 初始化RISC-V状态
    memset(&state, 0, sizeof(state)); // 将状态结构体初始化为0
    state.pc = MINIRV32_RAM_IMAGE_OFFSET; // 设置程序计数器为RAM的起始地址
    memcpy(ram, binary_data, binary_size); // 将二进制文件内容加载到RAM中
    
    free(binary_data); // 释放二进制文件数据

    // 打开日志文件
    FILE* log_file = fopen(log_file_name, "w");
    if (!log_file) {
        perror("Failed to open log file"); // 如果日志文件打开失败，输出错误信息
        free(ram);
        return 1;
    }

    uint32_t inst_count = 0;
    uint32_t old_pc = 0x7fffffff;
    // 模拟RISC-V程序的执行
    while (1) {
        uint32_t pc = state.pc; // 获取当前程序计数器值
        if (pc == old_pc) break; // 检测到死循环
        old_pc = pc;
        int32_t result = MiniRV32IMAStep(&state, ram, 0, 1, 1); // 执行一条指令
        inst_count++;

        // // 检查是否有寄存器被写入
        // uint32_t ir = *(uint32_t*)(ram + (pc - MINIRV32_RAM_IMAGE_OFFSET)); // 获取当前指令
        // uint32_t rdid = (ir >> 7) & 0x1f; // 提取目标寄存器编号
        // int write_reg = (rdid != 0) ? 1 : 0; // 判断是否写入了寄存器
        // uint32_t reg_value = (write_reg) ? state.regs[rdid] : 0; // 获取写入的寄存器值

        // 记录指令执行日志
        // log_instruction(log_file, pc, write_reg, rdid, reg_value);

        
        if (result != 0) {
            break; // 如果发生错误或程序结束，停止模拟
        }
    }

    // 清理资源
    fclose(log_file); // 关闭日志文件
    free(ram); // 释放RAM
    double ipc = (double)inst_count/state.timerl;
    printf("Simulation completed. \ntimer:%d\ninst_count:%d\nipc:%lf\n", state.timerl,inst_count,ipc); // 输出模拟完成信息
    return 0;
}