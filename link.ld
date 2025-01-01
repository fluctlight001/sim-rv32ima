ENTRY(_start)

SECTIONS {
    . = 0x80000000;  /* 程序加载地址 */
    .text : { *(.text) }
    .rodata : { *(.rodata) }
    .data : { *(.data) }
    .bss : { *(.bss) }

    /* 堆空间 */
    . = ALIGN(4);
    _heap_start = .;
    . = . + 0x10000; /* 64 KB 堆空间 */
    _heap_end = .;

    /* 栈空间 */
    . = ALIGN(4);
    _stack_start = .;
    . = . + 0x10000; /* 64 KB 栈空间 */
    _stack_end = .;
}