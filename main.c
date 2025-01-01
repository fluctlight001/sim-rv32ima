#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


#define MINI_RV32_RAM_SIZE (1024 * 1024)  // 1 MB RAM
#define MINIRV32_IMPLEMENTATION

#include "mini-rv32ima.h"

uint8_t ram[MINI_RV32_RAM_SIZE];

// 从二进制文件加载程序到内存
int load_program(const char *filename, uint8_t *ram, size_t ram_size) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("无法打开文件");
        return -1;
    }

    // 获取文件大小
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    // 检查文件是否超出内存范围
    if (file_size > ram_size) {
        fprintf(stderr, "错误: 文件大小超出内存范围！\n");
        fclose(file);
        return -1;
    }

    // 读取文件内容到内存
    size_t read_size = fread(ram, 1, file_size, file);
    if (read_size != file_size) {
        perror("读取文件失败");
        fclose(file);
        return -1;
    }

    fclose(file);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "用法: %s <二进制文件>\n", argv[0]);
        return 1;
    }

    // 从二进制文件加载程序到内存
    if (load_program(argv[1], ram, MINI_RV32_RAM_SIZE) != 0) {
        return 1;
    }

    // 初始化处理器状态
    struct MiniRV32IMAState state = {0};
    state.pc = 0x80000000;  // 设置初始 PC 值

    // 加载程序到内存
    // uint32_t program[] = {
    //     0x00000593,  // li a1, 0       (addi a1, zero, 0)
    //     0x06400313,  // li t1, 100     (addi t1, zero, 100)
    //     0x00000293,  // li t0, 0       (addi t0, zero, 0)
    //     0x00128293,  // addi t0, t0, 1 (t0 = t0 + 1)
    //     0x005585b3,  // add a1, a1, t0 (a1 = a1 + t0)
    //     0xfe62e8e3,  // blt t0, t1, -8 (如果 t0 < t1，跳转到 addi t0, t0, 1)
    //     0x00000073   // ecall          (结束程序)
    // };
    // memcpy(ram, program, sizeof(program));

    // 运行处理器
    while (1) {
        int ret = MiniRV32IMAStep(&state, ram, 0, 0, 1);
        if (ret != 0) {
            if (ret == -1) {
                printf("模拟器正常结束。\n");
            } else {
                printf("模拟器异常退出，返回值: %d\n", ret);
            }
            break;
        }
    }

    // 输出 a1 寄存器的最终值
    uint32_t a1_value = *(uint32_t *)(ram + 0x80000000 - MINIRV32_RAM_IMAGE_OFFSET);
    printf("a1 寄存器的最终值: %d\n", a1_value);

    return 0;
}