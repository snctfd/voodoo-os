default: all

.PHONY: all clean

CROSS_COMPILER_TARGET ?= i686-elf

ASSEMBLER ?= $(CROSS_COMPILER_TARGET)-as
LINKER ?= $(CROSS_COMPILER_TARGET)-ld

ASMOPS ?= -msyntax=intel
LINKOPS = --oformat binary

bootloader_stage1.bin: bootloader_stage1.S
	$(ASSEMBLER) $(ASMOPS) -o bootloader_stage1.o bootloader_stage1.S
	$(LINKER) $(LINKOPS) -o bootloader_stage1.bin bootloader_stage1.o \
						 -Ttext 0x7c00
# Make sure bootloader bin is correct size
	test `wc -c < "bootloader_stage1.bin"` -eq 446

bootloader_stage2.bin: bootloader_stage2.S
	$(ASSEMBLER) $(ASMOPS) -o bootloader_stage2.o bootloader_stage2.S
	$(LINKER) $(LINKOPS) -o bootloader_stage2.bin bootloader_stage2.o \
					     -Ttext 0x0

all: bootloader_stage1.bin bootloader_stage2.bin

clean:
	rm -f *.bin
	rm -r *.o
