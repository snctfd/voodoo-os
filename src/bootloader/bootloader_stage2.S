/*
 * --------------------------------------------------
 * File: bootloader_stage2.S
 * Date: 2018-06-27
 * Author: snctfd (Rasmus Beck)
 *  
 * Stage two of the bootloader.
 *  
 * --------------------------------------------------
 */

.code16
.intel_syntax noprefix
.global _start

_start:
jmp stage2_start

.include "util.S"

.equ DISKBUFFER_SEG,    0x1000
.equ DISKBUFFER_OFFSET, 0x0
.equ KERNEL_SEGMENT,    0x400

inf_start_msg:        .asciz "RUNNING STAGE 2 OF BOOTLOADER..."
inf_found_kernel:     .asciz "FOUND KERNEL"

err_read_fail:        .asciz "ATTEMPT TO READ DISK FAILED"
err_spc_invalid:      .asciz "INVALID SECTORS PER CLUSTER VALUE"
err_rsc_invalid:      .asciz "INVALID RESERVED SECTOR COUNT VALUE"
err_fc_invalid:       .asciz "INVALID FAT COUNT VALUE"
err_spf_invalid:      .asciz "INVALID SECTORS PER FAT VALUE"
err_kernel_not_found: .asciz "KERNEL NOT FOUND"
err_bad_cluster:      .asciz "BAD CLUSTER DETECTED"

error_str:            .asciz "ERROR: "
crash_msg:            .asciz "FUCK"

/*
 * --------------------------------------------------
 * disk_read
 * 
 * Reads data from the disk based on the contents of
 * DISK_ADDRESS_PACKET. Assumes DL contains the ID of
 * the boot disk.
 * --------------------------------------------------
 */
disk_read:
    mov dx, [disk_identifier]
    mov ah, 0x42
    mov si, offset DISK_ADDRESS_PACKET
    int 0x13

    jc .read_fail
    ret

.read_fail:
    mov si, offset err_read_fail
    jmp crash

/* -------------------------------------------------- */

crash:
    push si

    mov si, offset error_str
    call print_string

    pop si
    call print_line
    
    mov si, offset crash_msg
    call print_line

    cli
    hlt

/*
 * --------------------------------------------------
 * check_bpb_vals
 *
 * Makes sure that the data read from the BPB is
 * valid.
 * --------------------------------------------------
 */

check_bpb_vals:
    /* First variable: sectors per cluster */
    /* Allowed values: Any power of two. */
    /* It's hardcoded, because I just can't give a fuck. */

    mov ah, [bpb_secs_per_clus]

    cmp ah, 1
    je .spc_valid

    cmp ah, 2
    je .spc_valid

    cmp ah, 4
    je .spc_valid

    cmp ah, 8
    je .spc_valid

    cmp ah, 16
    je .spc_valid

    cmp ah, 32
    je .spc_valid

    cmp ah, 64
    je .spc_valid

    cmp ah, 128
    je .spc_valid
    
    /* Sectors per cluster was not valid */
    mov si, offset err_spc_invalid
    jmp crash

.spc_valid:

    /* Second variable: Reserved sector count */
    /* Allowed values: Any non-zero number */

    mov ax, [bpb_rsvd_sec_cnt]
    cmp ax, 0
    jne .rsc_valid

    /* Sectors per cluster was not valid */
    mov si, offset err_rsc_invalid
    jmp crash

.rsc_valid:
    
    /* Third variable: Number of FATs on the volume */
    /* Allowed values: Any non-zero number */

    mov ah, [bpb_fat_cnt]
    cmp ah, 0
    jne .fc_valid

    /* Sectors per cluster was not valid */
    mov si, offset err_fc_invalid
    jmp crash

.fc_valid:

    /* Fourth variable: Number of sectors occupied by each FAT */
    /* Allowed values: Any non-zero number */

    mov ax, [bpb_secs_per_fat_low]
    cmp ax, 0
    jne .spf_valid

    mov ax, [bpb_secs_per_fat_high]
    cmp ax, 0
    jne .spf_valid

    mov si, offset err_spf_invalid
    jmp crash

.spf_valid:
    ret
/*
 * --------------------------------------------------
 * cluster_to_lba
 *
 * Calculates the LBA of a given cluster
 *
 * Arguments:
 * BX:AX = Cluster number
 * 
 * Return:
 * BX:AX = Cluster LBA
 * --------------------------------------------------
 */
cluster_to_lba:
    push cx

    /* SECTOR_LBA = ((CLUSTER - 2) * SECS_PER_CLUS) + DATA_LBA */
    movzx cx, byte ptr [bpb_secs_per_clus]
    sub ax, 2
    jno .no_overflow_1
    sub bx, 1 /* Adjust for overflow */
.no_overflow_1:
    mul cx
    push ax /* Store low byte */
    mov ax, bx
    mov bx, dx /* Store overflow */
    mul cx
    add bx, ax /* Add overflow */

    pop ax
    mov cx, [data_lba_low]
    add ax, cx
    jno .no_overflow_2
    add bx, 1 /* Adjust for overflow */
.no_overflow_2:
    mov cx, [data_lba_high]
    add ax, cx

    pop cx
    ret

/* -------------------------------------------------- */

stage2_start:
    mov ax, 0x210
    mov ds, ax

    /* Setup GS for disk buffer data */
    mov ax, DISKBUFFER_SEG
    mov gs, ax

    mov [disk_identifier], dx

    call new_line
    mov si, offset inf_start_msg
    call print_line

    /* Enable A20 Line */
    in al, 0x92
    or al, 2
    out 0x92, al

    /* Get LBA of first absolute sector in the first partition. */

    mov word ptr [DAP_BLOCKCNT], 1
    call disk_read

    mov ax, gs:[DISKBUFFER_OFFSET + 0x1C6] /* Said LBA is at 0x1C6 */
    mov [partition_lba_low], ax
    mov [DAP_LBA_LOW], ax

    mov ax, gs:[DISKBUFFER_OFFSET + 0x1C8]
    mov [partition_lba_high], ax
    mov [DAP_LBA_HIGH], ax

    /* Get BIOS Parameter Block in the first sector of the partition */
    mov word ptr [DAP_BLOCKCNT], 1
    call disk_read

    /* Get number of sectors per cluster */
    mov ah, gs:[DISKBUFFER_OFFSET + 13]
    mov [bpb_secs_per_clus], ah

    /* Get number of reserved sectors */
    mov ax, gs:[DISKBUFFER_OFFSET + 14]
    mov [bpb_rsvd_sec_cnt], ax

    /* Get number of FATs in the partition */
    mov ah, gs:[DISKBUFFER_OFFSET + 16]
    mov [bpb_fat_cnt], ah

    /* Get number of sectors per FAT */
    mov ax, gs:[DISKBUFFER_OFFSET + 36]
    mov [bpb_secs_per_fat_low], ax

    mov ax, gs:[DISKBUFFER_OFFSET + 38]
    mov [bpb_secs_per_fat_high], ax

    /* Get cluster number of the first cluster of the root directory */
    mov ax, gs:[DISKBUFFER_OFFSET + 44]
    mov [bpb_rootcluster_low], ax
    mov [current_cluster_low], ax 

    mov ax, gs:[DISKBUFFER_OFFSET + 46]
    mov [bpb_rootcluster_high], ax
    mov [current_cluster_high], ax 

    call check_bpb_vals

    /* FAT_LBA = PARTITION_LBA + RESERVED_SECTORS */
    mov ax, [partition_lba_low]
    mov bx, [bpb_rsvd_sec_cnt]
    add ax, bx
    mov [fat_lba_low], ax

    mov ax, [partition_lba_high]
    jno .no_overflow_fat_lba
    add ax, 1 /* Adjust for overflow */
.no_overflow_fat_lba:
    mov [fat_lba_high], ax

    /* DATA_LBA = FAT_LBA + (FAT_COUNT * FAT_SIZE) */
    mov ax, [bpb_rootcluster_low]
    movzx bx, byte ptr [bpb_fat_cnt]
    mul bx
    mov [data_lba_low], ax
    mov cx, dx /* Store upper word */
    mov ax, [bpb_rootcluster_high]
    mul bx
    add ax, cx /* Add upper word from last calculation */
    mov [data_lba_high], ax

    /* Add FAT_LBA */
    mov ax, [data_lba_low]
    mov bx, [fat_lba_low]
    add ax, bx
    mov [data_lba_low], ax
    
    mov ax, [data_lba_high]
    mov bx, [fat_lba_high]
    jno .no_overflow_data_lba
    add ax, 1 /* Adjust for overflow in low word addition */
.no_overflow_data_lba:
    add ax, bx
    mov [data_lba_high], ax 

    /* ENTRIES_PER_CLUSTER = (512/32) * SECTORS_PER_CLUSTER */
    movzx ax, byte ptr [bpb_secs_per_clus]
    shl ax, 4 /* Equivalent to multiplying by 2^4 = 16 = (512 / 32) */
    mov [entries_per_clus], ax

    /* -------------------------------------------------- */
    
    /* Time to read the root directory! */

    /* Calculate LBA of the first sector of the cluster */
    mov ax, [bpb_rootcluster_low]
    mov bx, [bpb_rootcluster_high]

    call cluster_to_lba

    mov [DAP_LBA_LOW], ax
    mov [DAP_LBA_HIGH], bx

    /* Read the cluster: */
    movzx ax, byte ptr [bpb_secs_per_clus]
    mov [DAP_BLOCKCNT], ax
    call disk_read

    xor ax, ax /* AX contains the number of the current dir entry */
    xor bx, bx /* BX contains the first byte of the current dir entry */
    .read_entry:
        /* First byte of the directory entry */
        mov dx, gs:[DISKBUFFER_OFFSET + bx] 
        cmp dh, 0       /* We've run out of root directory! This is bad. */
        je kernel_not_found /* Abandon ship! D: */

        cmp dx, 0x454B   /* EK */
        jne .next_entry
        
        mov dx, gs:[DISKBUFFER_OFFSET + bx + 2]
        
        cmp dx, 0x4E52   /* NR */
        jne .next_entry

        mov dx, gs:[DISKBUFFER_OFFSET + bx + 4]
        
        cmp dx, 0x4C45   /* LE */
        jne .next_entry

        mov dx, gs:[DISKBUFFER_OFFSET + bx + 6] 
        
        cmp dx, 0x2020   /* Space, space */
        jne .next_entry

        mov dx, gs:[DISKBUFFER_OFFSET + bx + 8] 
        
        cmp dx, 0x4942   /* IB */
        jne .next_entry

        mov dh, gs:[DISKBUFFER_OFFSET + bx + 10] 

        cmp dh, 0x4E     /* N */
        je .kernel_found

    .next_entry:
        inc ax
        mov cx, [entries_per_clus]
        cmp ax, cx
        jae .next_cluster

        add bx, 32

        jmp .read_entry

    .next_cluster:
        /* TODO support FATs that span across more than */
        /* 2 bytes worth of blocks */
        /* This will involve major pain-in-the-ass arithmetic */
        /* I love ASM */
        mov ax, [current_cluster_low]
        /* (current cluster * 4 bytes per entry) / 512 bytes per cluster */
        shr ax, 7
        mov bx, [fat_lba_low]
        add ax, bx
        
        mov [DAP_LBA_LOW], ax
        mov word ptr [DAP_LBA_HIGH], 0
        mov word ptr [DAP_BLOCKCNT], 1
        
        call disk_read

        mov bx, [current_cluster_low]
        and bx, 511 /* current_cluster & 511 = (current_cluster) mod 512 */

        mov ax, gs:[DISKBUFFER_OFFSET + bx]    /* Low word */
        mov bx, gs:[DISKBUFFER_OFFSET + bx + 2] /* High word */

        cmp bx, 0x0FFF
        jl .good

        /* Uh oh, we might be in trouble */
        /* Are we though? */

        cmp ax, 0xFFF7
        je bad_cluster

        cmp ax, 0xFFF8
        jge kernel_not_found

        /* Nah, we good */
    .good:
        mov [current_cluster_low], ax
        mov [current_cluster_high], bx
        call cluster_to_lba

        mov cl, [bpb_secs_per_clus]

        mov [DAP_LBA_LOW], ax
        mov [DAP_LBA_HIGH], bx
        mov [DAP_BLOCKCNT], cl
        
        call disk_read

        xor ax, ax
        xor bx, bx

        jmp .read_entry
        
    .kernel_found:
        mov si, offset inf_found_kernel
        call print_line

        cli
        hlt

kernel_not_found:
    mov si, offset err_kernel_not_found
    jmp crash

bad_cluster:
    mov si, offset err_bad_cluster
    jmp crash

/*
 * Variables
 */

disk_identifier:       .hword 0

current_cluster_low:   .hword 0
current_cluster_high:  .hword 0

partition_lba_low:     .hword 0 /* LBA of the first partition */
partition_lba_high:    .hword 0 

fat_lba_low:           .hword 0 /* LBA of the first FAT */
fat_lba_high:          .hword 0 

data_lba_low:          .hword 0 /* LBA of the data section */
data_lba_high:         .hword 0

entries_per_clus:      .hword 0 /* Number of directory entries per cluster */

bpb_secs_per_clus:     .byte  0 /* Sectors per cluster */

bpb_rsvd_sec_cnt:      .hword 0 /* Number of reserved sectors */

bpb_fat_cnt:           .byte  0 /* Number of FATs */

bpb_secs_per_fat_low:  .hword 0 /* Low  2 bytes of sectors per FAT */
bpb_secs_per_fat_high: .hword 0 /* High 2 bytes of sectors per FAT */

bpb_rootcluster_low:   .hword 0 /* The cluster number of the first cluster of the */
bpb_rootcluster_high:  .hword 0 /* root directory. */

/* -------------------------------------------------- */

DISK_ADDRESS_PACKET:
DAP_SIZE:     .byte  0x00 /* Size of disk packet */
DAP_RESERVED: .byte  0x00 /* (▀̿Ĺ̯▀̿) Nothing to see here, move along citizen (▀̿Ĺ̯▀̿)  */
DAP_BLOCKCNT: .hword 0x00 /* Number of blocks to read */
DAP_OFFSET:   .hword DISKBUFFER_OFFSET /* The offset of the read buffer */
DAP_SEGMENT:  .hword DISKBUFFER_SEG    /* The segment of the read buffer */
DAP_LBA_LOW:  .long  0x01 /* Block number, part 1. */
DAP_LBA_HIGH: .long  0x00 /* Block number, part 2. */

/* -------------------------------------------------- */