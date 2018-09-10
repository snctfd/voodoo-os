.PHONY: default clean bootloader compile setup setup-cross-compiler \
cross-compiler-clean kernel

export CROSS_COMPILER_INSTALLDIR ?= /usr/local/cross/
export CROSS_COMPILER_TARGET ?= i686-elf
export ASSEMBLER := $(CROSS_COMPILER_TARGET)-as
export CROSS_COMPILER := $(CROSS_COMPILER_TARGET)-gcc
export LINKER := $(CROSS_COMPILER_TARGET)-ld
export PATH := $(CROSS_COMPILER_INSTALLDIR)/bin:$(PATH)

export ASMOPS = -wall -msyntax=intel -mmnemonic=intel

export COPS = -Wall -nostdlib -nostartfiles -ffreestanding \
	   -Iinclude -mgeneral-regs-only -fno-exceptions -fno-rtti

export LINKOPS = -ffreestanding -O2 -nostdlib -lgcc

LOOPBACKDEVICE != sudo losetup -f

default: voodoo_os.img

bootloader: bootloader_stage1.bin bootloader_stage2.bin

bootloader_stage1.bin: force_look
	cd src/bootloader; $(MAKE) bootloader_stage1.bin

bootloader_stage2.bin: force_look
	cd src/bootloader; $(MAKE) bootloader_stage2.bin

kernel: force_look
	cd src/kernel; $(MAKE) kernel.bin

voodoo_os.img: compile
	dd if=/dev/zero of=voodoo_os.img bs=504K count=1000

	(echo n; echo p; echo 1; echo ""; echo ""; echo t; echo c; echo a; echo w;)\
	 | sudo fdisk -u -C1000 -S63 -H16 voodoo_os.img

# n:  New partition
# p:  Primary partition
# 1:  ID 1
# "": Default first sector
# "": Default last sector
# t:  Change partition type
# c:  Type: W95 FAT32 (LBA)
# a:  Toggle bootable flag
# w:  Write changes to disk

	mkdir -p mnt/fake/
	
	dd if=src/bootloader/bootloader_stage1.bin of=voodoo_os.img conv=notrunc
	dd if=src/bootloader/bootloader_stage2.bin of=voodoo_os.img conv=notrunc seek=1

	sudo losetup -o1MiB $(LOOPBACKDEVICE) voodoo_os.img
	sudo mkdosfs -v -F32 $(LOOPBACKDEVICE)
	sudo mount -t vfat $(LOOPBACKDEVICE) mnt/fake/ 

	sudo mkdir mnt/fake/bin/
	sudo mkdir mnt/fake/sys/
	sudo mkdir mnt/fake/dev/
	sudo mkdir mnt/fake/proc/

	sudo cp src/kernel/kernel.bin mnt/fake/

	sleep 0.1

	sudo umount mnt/fake/
	sudo losetup -d $(LOOPBACKDEVICE)

compile: bootloader kernel

clean: cross-compiler-clean
	cd src/bootloader; $(MAKE) clean
	cd src/kernel; $(MAKE) clean

	rm -f *.bin
	rm -f voodoo_os.img

setup-cross-compiler:
	cd src/util/; \
	sudo $(MAKE) binutils-make && \
	sudo $(MAKE) gcc-make

cross-compiler-clean:
	cd src/util/; sudo $(MAKE) clean

force_look:
	true