.PHONY: default clean bootloader compile

export COMPILER ?= gcc
export ASSEMBLER ?= nasm

export COPS = -Wall -nostdlib -nostartfiles -ffreestanding \
	   -Iinclude -mgeneral-regs-only

export ASMOPS = -w+all -f bin

LOOPBACKDEVICE != sudo losetup -f

default: voodoo_os.flp

bootloader: bootloader_stage1.bin

bootloader_stage1.bin: force_look
	cd src/bootloader; $(MAKE) bootloader_stage1.bin

voodoo_os.img:
	dd if=/dev/zero of=voodoo_os.img bs=516096c count=1000


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

voodoo_os.flp: compile voodoo_os.img 
	mkdir -p mnt/fake/
	
	dd if=src/bootloader/bootloader_stage1.bin of=voodoo_os.img conv=notrunc

	sudo losetup -o1048576 $(LOOPBACKDEVICE) voodoo_os.img
	sudo mkdosfs -v -F32 $(LOOPBACKDEVICE)
	sudo mount -t vfat $(LOOPBACKDEVICE) mnt/fake/ 

	sudo mkdir mnt/fake/bin/
	sudo mkdir mnt/fake/sys/
	sudo mkdir mnt/fake/dev/
	sudo mkdir mnt/fake/proc/

	sleep 1

	sudo umount mnt/fake/
	sudo losetup -d $(LOOPBACKDEVICE)

compile: bootloader

clean:
	cd src/bootloader $(MAKE) clean

	rm -f *.bin
	rm -f voodoo_os.img

force_look:
	true