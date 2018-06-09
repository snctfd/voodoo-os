;--------------------------------------------------
; File: bootloader_stage1.S
; Date: 2018-06-08
; Author: snctfd (Rasmus Beck)
; 
; This file implements the first stage of the bootloader.
; Turns out, having one of those is pretty nifty.
; 
;--------------------------------------------------

org 0x7C00 ; Initial load is at 0x7C00

bits 16    ; We're in 16 bit mode

helloworld db "Hello World!", 0

jmp init_bootloader

;--------------------------------------------------
; printstr
; DS:SI: null-terminated string
;--------------------------------------------------

printstr:
    mov ah, 0x0E ; Print character code
    lodsb        ; Loads a byte from SI to AL
    or al, al
    jz done
    int 0x10
    jmp printstr
done:
    ret

init_bootloader:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, helloworld
    call printstr

    cli     ; Disable interrupts
    hlt     ; Halt

times 510 - ($-$$) db 0 ; Make sure file is 512 bytes
                        ; by filling the rest with 0s

dw 0xAA55 ; The BIOS boot signature