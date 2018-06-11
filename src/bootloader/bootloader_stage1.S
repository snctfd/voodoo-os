;--------------------------------------------------
; File: bootloader_stage1.S
; Date: 2018-06-11
; Author: snctfd (Rasmus Beck)
; 
; This file implements the first stage of the bootloader.
; Turns out, having one of those is pretty nifty.
; The purpose of this file is simply to load in
; the second stage of the bootloader.
; 
;--------------------------------------------------

org 0x7C00 ; Initial load is at 0x7C00

bits 16    ; We're in 16 bit mode

jmp init_bootloader

start_msg     db "RUNNING STAGE 1 OF BOOTLADER...", 0
no_edr_msg    db "BIOS EXTENSIONS NOT SUPPORTED", 0
read_fail_msg db "FAILED TO READ FROM DISK", 0
stage2_msg    db "READY TO LOAD STAGE 2", 0
crash_msg     db "FUCK", 0

%include "util.S"

init_bootloader:

    ; Setup stack and data segment
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov sp, 0x2000 ; Allocate 2K for stack

    push dx ; Save boot disk ID

    ; Set cursor at (0,0)
    mov ah, 0x02
    xor dh, dh
    xor dl, dl
    int 0x10

    ; Clear screen
    mov ah, 0x06
    xor al, al
    xor bx, bx
    mov bh, 0x07
    xor cx, cx
    mov dh, 24
    mov dl, 79
    int 0x10

    mov si, start_msg
    call print_line
    
    pop dx
    push dx

    ; Check if LBA is available
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13

    jc edd_not_supported

    pop dx ; Fetch boot disk ID

    mov si, stage2_msg
    call print_line

    ; Read stage 2 from the disk
    mov ah, 0x42
    mov si, DISK_ADDRESS_PACKET
    int 0x13

    jc read_fail

    ; Jump to stage 2
    jmp 0x210:0x0

edd_not_supported:
    mov si, no_edr_msg
    call print_line
    jmp crash

read_fail:
    mov si, read_fail_msg
    call print_line
    jmp crash

crash:
    mov si, crash_msg
    call print_line
    cli
    hlt

DISK_ADDRESS_PACKET:
.size     db 0x10   ; Size of disk packet
.reserved db 0x00   ; (▀̿Ĺ̯▀̿) Nothing to see here, move along citizen (▀̿Ĺ̯▀̿) 
.blockcnt dw 0x03   ; Number of blocks to read
.offset   dw 0x00   ; The offset of the read buffer
.segment  dw 0x0210 ; The segment of the read buffer
.lba      dd 0x01   ; Block number, part 1.
.lba48    dd 0x00   ; Block number, part 2.

times 446 - ($-$$) db 0 ; Make sure file is 446 bytes
                        ; by filling the rest with 0s

dw 0xAA55 ; The BIOS boot signature