include $(BASE)/mkinclude/cross.mk

CC := $(CROSS_TARGET)-gcc
CXX := $(CROSS_TARGET)-g++

C_INCLUDE = -I../include -Iinclude

C_WARN_FLAGS = -Wall -Wextra -pedantic

COMMON_C_FLAGS = $(C_INCLUDE) -nostdlib -nostartfiles -ffreestanding \
	-mgeneral-regs-only -masm=intel -O2
COMMON_CPP_FLAGS = $(COMMON_C_FLAGS) -fno-rtti -std=c++11 -fno-exceptions

DISABLE_SSE_FLAGS = -mno-sse -mno-sse2 -mno-sse3 \
					-mno-sse4 -mno-sse4.1 -mno-sse4.2

ENABLE_AVX_FLAGS=-mavx -mavx2

C_LOW = -march=i386 -fno-strict-aliasing -fno-pic -fno-toplevel-reorder \
	$(DISABLE_SSE_FLAGS) $(DISABLE_AVX_FLAGS)
C_16_BIT = $(C_LOW) -m16 -mregparm=3 -mpreferred-stack-boundary=2
C_32_BIT = $(C_LOW) -m32 -mpreferred-stack-boundary=4