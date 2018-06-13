;--------------------------------------------------
; File: bootloader_stage2.S
; Date: 2018-06-11
; Author: snctfd (Rasmus Beck)
; 
; Stage two of the bootloader.
; 
;--------------------------------------------------

bits 16

jmp stage2_start

start_msg db "RUNNING STAGE 2 OF BOOTLOADER...", 0

%include "util.S"

stage2_start:
    mov ax, 0x210
    mov ds, ax

    mov si, start_msg
    call print_line

    ; Enable A20 Line
    in al, 0x92
    or al, 2
    out 0x92, al

    cli
    hlt