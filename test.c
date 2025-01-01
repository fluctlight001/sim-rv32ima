#include <stdint.h>

void main() __attribute__((naked));
void main() {
    // 初始化栈指针
    asm volatile("lui sp, 0x80010");  // 将 sp 初始化为 0x80010000
    asm volatile("addi sp, sp, -32"); // 调整栈指针

    int a1 = 0;
    for (int i = 1; i <= 100; i++) {
        a1 += i;
    }

    // 将 a1 的值写入内存，避免被优化
    *(volatile int *)0x80000000 = a1;

    // 通知模拟器程序结束
    *(volatile uint32_t *)0x10000000 = 0xDEADBEEF;

    while (1);  // 无限循环，模拟程序结束
}