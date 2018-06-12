default: all

.PHONY: all clean

ASSEMBLER ?= nasm
ASMOPS ?= -w+all -f bin

bootloader_stage1.bin: bootloader_stage1.S
	$(ASSEMBLER) $(ASMOPS) -o bootloader_stage1.bin bootloader_stage1.S
# Make sure bootloader bin is correct size
	test `wc -c < "bootloader_stage1.bin"` -eq 446

bootloader_stage2.bin: bootloader_stage2.S
	$(ASSEMBLER) $(ASMOPS) -o bootloader_stage2.bin bootloader_stage2.S

all: bootloader_stage1

clean:
	rm -f bootloader_stage1.bin
