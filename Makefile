.PHONY: default clean bootloader compile setup setup-cross-compiler \
cross-compiler-clean kernel

LOOPBACKDEVICE != sudo losetup -f

export BASE = $(CURDIR)

default: voodoo_os.img

bootloader: bootloader_stage1.bin bootloader_stage2.bin

bootloader_stage1.bin: force_look
	cd bootloader; $(MAKE) bootloader_stage1.bin

bootloader_stage2.bin: force_look
	cd bootloader; $(MAKE) bootloader_stage2.bin

kernel: force_look
	cd kernel; $(MAKE) kernel.bin

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
	
	dd if=bootloader/bootloader_stage1.bin of=voodoo_os.img conv=notrunc
	dd if=bootloader/bootloader_stage2.bin of=voodoo_os.img conv=notrunc seek=1

	sudo losetup -o1MiB $(LOOPBACKDEVICE) voodoo_os.img
	sudo mkdosfs -v -F32 $(LOOPBACKDEVICE)
	sudo mount -t vfat $(LOOPBACKDEVICE) mnt/fake/ 

	sudo mkdir mnt/fake/bin/
	sudo mkdir mnt/fake/sys/
	sudo mkdir mnt/fake/dev/
	sudo mkdir mnt/fake/proc/

	sudo cp kernel/kernel.bin mnt/fake/

	sleep 0.1

	sudo umount mnt/fake/
	sudo losetup -d $(LOOPBACKDEVICE)

compile: bootloader kernel

clean: cross-compiler-clean
	cd bootloader; $(MAKE) clean
	cd kernel; $(MAKE) clean

	rm -f *.bin
	rm -f voodoo_os.img

setup-cross-compiler:
	cd util; \
	sudo $(MAKE) binutils-make && \
	sudo $(MAKE) gcc-make

cross-compiler-clean:
	cd util; $(MAKE) clean

force_look:
	true