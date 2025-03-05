ENTRY(_start)

SECTIONS
{
    . = 0x80000000;

    /* 确保 _start 函数位于 .text 段的开头 */
    .text : {
        *(.text._start) /* 显式放置 _start 函数 */
        *(.text*)       /* 其他代码 */
    }

    .rodata : { *(.rodata*) }
    .data : { *(.data*) }
    .bss : { *(.bss*) }
}