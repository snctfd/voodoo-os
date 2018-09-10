SECTIONS
{
    /* Sections start at 0x6000 bytes */
    . = 0x6000;

    /* Code */
    .text_16 BLOCK(512) : ALIGN(512)
    {
        kinit16_64.o(.text)
    }

    /* Read-only data */
    .rodata_16 BLOCK(512) : ALIGN(512)
    {
        kinit16_64.o(.rodata)
    }

    /* Read-write data */
    .data_16 BLOCK(512) : ALIGN(512)
    {
        kinit16_64.o(.data)
    }

    /* BSS (uninitialized read-write data) and stack */
    .bss_16 BLOCK(512) : ALIGN(512)
	{
		kinit16_64.o(.bss)
	}

    /* 32 bit code */
    .text_32 BLOCK(512) : ALIGN(512) 
    {
        kinit32_64.o(.text)
    }

    /* Read-only data */
    .rodata BLOCK(4K) : ALIGN(4K) {
        *(.rodata)
    }

    /* Read-write data */
    .data BLOCK(4K) : ALIGN(4K) {
        *(.data)
    }

    /* BSS (uninitialized read-write data) and stack */
    .bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}
} 