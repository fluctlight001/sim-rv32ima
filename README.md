# sim-rv32ima

### 前置环节

1. 在ysyx-workbench中编译测试
2. 将测试文件转移到test目录下

### 使用流程

1. gcc -o riscv_simulator main.c // 编译riscv_simulator
2. ./riscv_simulator test/dummy-riscv32-ni.bin  simulator.log // 单独运行某个bin文件
3. disassemble_riscv.sh // 生成反汇编文件，产物在disasm/
4. conver_bin_to_data.sh // 生成data文件（16进制文件）用于vivado仿真
5. golden_trace.sh // 生成trace文件，用于vivado仿真时比对结果

### 废弃文件

~~build_and_run.sh~~

~~build.sh~~

~~link.ld~~

~~rv32sim~~