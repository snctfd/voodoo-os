.PHONY: default clean

include $(BASE)/mkinclude/cpp.mk
include $(BASE)/mkinclude/oc.mk

OBJ_FILES = \
	kinit16_64.o \
	kinit32_64.o

default: kernel.bin

kinit16.o: src/kinit16.cpp
	$(CXX) -c $< -o $@ $(COMMON_CPP_FLAGS) \
		$(C_WARN_FLAGS) $(C_16_BIT) $(C_INCLUDE)

kinit32.o: src/kinit32.cpp
	$(CXX) -c $< -o $@ $(COMMON_CPP_FLAGS) \
		$(C_WARN_FLAGS) $(C_32_BIT) $(C_INCLUDE)

%_64.o: %.o
	$(OC) $(OC_32_TO_64) $< $@

kernel.bin: $(OBJ_FILES) linker.ld
	$(CC) -lgcc -T linker.ld -o $@ $(OBJ_FILES) \
	 $(COMMON_CPP_FLAGS) $(C_WARN_FLAGS)

clean:
	rm -f *.o
	rm -f *.bin