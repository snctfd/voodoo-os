.PHONY: all clean binutils-make gcc-make binutils-clean gcc-clean

include $(BASE)/mkinclude/cross.mk

all:
	$(MAKE) binutils-make
	$(MAKE) gcc-make

clean: binutils-clean gcc-clean

binutils-make: binutils-clean
	mkdir binutils-build

	cd binutils-build; \
	../binutils/configure --target=$(CROSS_TARGET) \
	--prefix="$(CROSS_INSTALL_DIR)" --with-sysroot --disable-nls \
	--disable-werror && \
	$(MAKE) && \
	$(MAKE) install

gcc-make: gcc-clean
	mkdir gcc-build

	cd gcc-build; \
	../gcc/configure --target=$(CROSS_TARGET) \
	--prefix="$(CROSS_INSTALL_DIR)" --disable-nls \
	--enable-languages=c,c++ --without-headers && \
	make all-gcc && \
	make all-target-libgcc && \
	make install-gcc && \
	make install-target-libgcc

binutils-clean:
	rm -rf binutils-build

gcc-clean:
	rm -rf gcc-build