default: all

.PHONY: all clean

ASSEMBLER ?= nasm
ASMOPS ?= -w+all -f bin

bootloader_stage1.bin: bootloader_stage1.S
	$(ASSEMBLER) $(ASMOPS) -o bootloader_stage1.bin bootloader_stage1.S

all: bootloader_stage1

clean:
	rm -f bootloader_stage1.bin
