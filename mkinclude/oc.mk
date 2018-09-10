include $(BASE)/mkinclude/cross.mk

OC = $(CROSS_TARGET)-objcopy

OC_32_TO_64 = -I elf32-i386 -O elf64-x86-64