ENTRY(_start)

SECTIONS
{
    /* Sections start at 1MiB */
    . = 1M;

    /* Code */
    .text BLOCK(4K) : ALIGN(4K) {
        *(.start)
        *(.text)
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