include $(BASE)/mkinclude/cross.mk

AS := $(CROSS_TARGET)-as

COMMON_ASM_FLAGS = -wall -msyntax=intel -mmnemonic=intel