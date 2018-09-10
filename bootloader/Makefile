default: all

.PHONY: all clean

include $(BASE)/mkinclude/asm.mk
include $(BASE)/mkinclude/lnk.mk

ASM_LNK_FLAGS = --oformat=binary

bootloader_stage1.bin: bootloader_stage1.S
	$(AS) $(COMMON_ASM_FLAGS) -o bootloader_stage1.o bootloader_stage1.S
	$(LD) $(ASM_LNK_FLAGS)    -o bootloader_stage1.bin bootloader_stage1.o \
						        -Ttext 0x7c00
# Make sure bootloader bin is correct size
	test `wc -c < "bootloader_stage1.bin"` -eq 446

bootloader_stage2.bin: bootloader_stage2.S
	$(AS) $(COMMON_ASM_FLAGS) -o bootloader_stage2.o bootloader_stage2.S
	$(LD) $(ASM_LNK_FLAGS)    -o bootloader_stage2.bin bootloader_stage2.o \
					            -Ttext 0x0

all: bootloader_stage1.bin bootloader_stage2.bin

clean:
	rm -f *.bin
	rm -r *.o
