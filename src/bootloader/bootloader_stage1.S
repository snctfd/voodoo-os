;--------------------------------------------------
; File: bootloader_stage1.S
; Date: 2018-06-08
; Author: snctfd (Rasmus Beck)
; 
; This file implements the first stage of the bootloader.
; Turns out, having one of those is pretty nifty.
; 
;--------------------------------------------------

org 0x7c00 ; Initial load is at 0x7c00

bits 16    ; We're in 16 bit mode

init_bootloader:
    cli     ; Disable interrupts
    hlt     ; Halt

times 510 - ($-$$) db 0x90 ; Make sure file is 512 bytes by filling the rest
                           ; with NOPs

dw 0xaa55 ; The BIOS boot signature