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

%include "util.S"
%include "definitions.S"

%define DISKBUFFER_SEG  0x1000
%define DISKBUFFER_OFFSET 0x0

start_msg     db "RUNNING STAGE 2 OF BOOTLOADER...", 0
read_fail_msg db "ATTEMPT TO READ DISK FAILED", 0
crash_msg     db "FUCK", 0

;--------------------------------------------------
; disk_read
; 
; Reads data from the disk based on the contents of
; DISK_ADDRESS_PACKET. Assumes DL contains the ID of
; the boot disk.
;--------------------------------------------------

disk_read:
    mov ah, 0x42
    mov si, DISK_ADDRESS_PACKET
    int 0x13

    jc .read_fail
    ret

.read_fail:
    mov si, read_fail_msg
    call print_line
    jmp crash

;--------------------------------------------------

crash:
    mov si, crash_msg
    call print_line
    jmp $

;--------------------------------------------------

stage2_start:
    mov ax, 0x210
    mov ds, ax

    ; Setup GS for disk buffer data
    mov ax, DISKBUFFER_SEG
    mov gs, ax

    call new_line
    mov si, start_msg
    call print_line

    ; Enable A20 Line
    in al, 0x92
    or al, 2
    out 0x92, al

    cli
    hlt

DISK_ADDRESS_PACKET:
.size     db 0x10   ; Size of disk packet
.reserved db 0      ; (▀̿Ĺ̯▀̿) Nothing to see here, move along citizen (▀̿Ĺ̯▀̿) 
.blockcnt dw 0      ; Number of blocks to read
.offset   dw DISKBUFFER_OFFSET ; The offset of the read buffer
.segment  dw DISKBUFFER_SEG    ; The segment of the read buffer
.lba      dd 0      ; Block number, part 1.
.lba48    dd 0      ; Block number, part 2.
