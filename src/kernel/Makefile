.PHONY: default clean

CROSS_COMPILER_TARGET ?= i686-elf
CROSS_COMPILER ?= $(CROSS_COMPILER_TARGET)-gcc
LINKER ?= $(CROSS_COMPILER_TARGET)-ld

COPS ?= -Wall -nostdlib -nostartfiles -ffreestanding \
	   -Iinclude -mgeneral-regs-only -fno-exceptions -fno-rtti

LINKOPS ?= -ffreestanding -O2 -nostdlib -lgcc

default: kernel.bin

kernel.bin: main.o
	$(CROSS_COMPILER) -T linker.ld -o kernel.bin main.o $(LINKOPS)

main.o:
	$(CROSS_COMPILER) -c main.cpp -o main.o

clean:
	rm -f *.o
	rm -f *.bin