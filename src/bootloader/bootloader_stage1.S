/*
 * --------------------------------------------------
 * File: bootloader_stage1.S
 * Date: 2018-06-27
 * Author: snctfd (Rasmus Beck)
 * 
 * This file implements the first stage of the bootloader.
 * Turns out, having one of those is pretty nifty.
 * The purpose of this file is simply to load in
 * the second stage of the bootloader.
 * 
 * --------------------------------------------------
*/
.code16
.intel_syntax noprefix

.text
    .globl _start;
_start:
ljmp 0, init_bootloader

start_msg:     .asciz "RUNNING STAGE 1 OF BOOTLOADER..."
no_edr_msg:    .asciz "BIOS EXTENSIONS NOT SUPPORTED"
read_fail_msg: .asciz "FAILED TO READ FROM DISK"
stage2_msg:    .asciz "READY TO LOAD STAGE 2"
crash_msg:     .asciz "FUCK"

.include "util.S"

init_bootloader:
    /* Setup stack and data segment */
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x1500

    push dx /* Save boot disk ID */

    /* Set cursor at (0,0) */
    mov ah, 0x02
    xor dh, dh
    xor dl, dl
    int 0x10

    /* Clear screen */
    mov ah, 0x06
    xor al, al
    xor bx, bx
    mov bh, 0x07
    xor cx, cx
    mov dh, 24
    mov dl, 79
    int 0x10

    mov si, offset start_msg
    call print_line
    
    pop dx
    push dx

    /* Check if LBA is available */
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13

    jc edd_not_supported
    
    mov si, offset stage2_msg
    call print_line

    pop dx /* Fetch boot disk ID */

    /* Read stage 2 from the disk */
    mov ah, 0x42
    mov si, offset DISK_ADDRESS_PACKET
    int 0x13

    jc read_fail

    /* Jump to stage 2 */
    ljmp 0x210, 0x0

edd_not_supported:
    mov si, offset no_edr_msg
    call print_line
    jmp crash

read_fail:
    mov si, offset read_fail_msg
    call print_line
    jmp crash

crash:
    mov si, offset crash_msg
    call print_line
    cli
    hlt

DISK_ADDRESS_PACKET:
size:     .byte  0x10   /* Size of disk packet */
reserved: .byte  0x00   /* (▀̿Ĺ̯▀̿) Nothing to see here, move along citizen (▀̿Ĺ̯▀̿)  */
blockcnt: .hword 0x03   /* Number of blocks to read */
offset:   .hword 0x00   /* The offset of the read buffer */
segment:  .hword 0x0210 /* The segment of the read buffer */
lba:      .long  0x01   /* Block number, part 1. */
lba48:    .long  0x00   /* Block number, part 2. */

.fill 446 - (.-_start) /* Make sure file is 446 bytes */
                       /* by filling the rest with 0s */
