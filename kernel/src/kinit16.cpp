/*
 * --------------------------------------------------
 * File: kinit.cpp
 * Date: 2018-07-06
 * Author: snctfd (Rasmus Beck)
 * 
 * The kernel initialization implementation.
 * 
 * --------------------------------------------------
 */

#include <stdio.hpp>
#include "gdt.hpp"
#include "boot.hpp"

gdt::gdt_descriptor_t gdt_array[7];
gdt::gdt_ptr_t gdt_ptr;

gdt::tss_t tss;

gdt::gdt_descriptor_t gdt_null_descriptor() {
    gdt::gdt_descriptor_t descriptor;

    descriptor.limit_low  = 0;
    descriptor.limit_high = 0;

    descriptor.base_low  = 0;
    descriptor.base_high = 0;

    descriptor.accessed   = 0;
    descriptor.rw         = 0;
    descriptor.dc         = 0;
    descriptor.executable = 0;
    descriptor.always_1   = 0;
    descriptor.privilege  = 0;
    descriptor.present    = 0;
    descriptor.avl        = 0;
    descriptor.long_mode  = 0;
    descriptor.size       = 0;
    descriptor.page       = 0;

    return descriptor;
}

gdt::gdt_descriptor_t gdt_kernel_code_descriptor() {
    gdt::gdt_descriptor_t descriptor;

    descriptor.limit_low  = 0xffff;
    descriptor.limit_high = 0xf;

    descriptor.base_low  = 0;
    descriptor.base_high = 0;

    descriptor.accessed   = 0;
    descriptor.rw         = 1;
    descriptor.dc         = 0;
    descriptor.executable = 1;
    descriptor.always_1   = 1;
    descriptor.privilege  = 0;
    descriptor.present    = 1;
    descriptor.avl        = 0;
    descriptor.long_mode  = 1;
    descriptor.size       = 0;
    descriptor.page       = 1;

    return descriptor;
}

gdt::gdt_descriptor_t gdt_kernel_code_descriptor_32() {
    gdt::gdt_descriptor_t descriptor;

    descriptor.limit_low  = 0xffff;
    descriptor.limit_high = 0xf;

    descriptor.base_low  = 0;
    descriptor.base_high = 0;

    descriptor.accessed   = 0;
    descriptor.rw         = 1;
    descriptor.dc         = 0;
    descriptor.executable = 1;
    descriptor.always_1   = 1;
    descriptor.privilege  = 0;
    descriptor.present    = 1;
    descriptor.avl        = 0;
    descriptor.long_mode  = 0;
    descriptor.size       = 1;
    descriptor.page       = 1;

    return descriptor;
}

gdt::gdt_descriptor_t gdt_kernel_data_descriptor() {
    gdt::gdt_descriptor_t descriptor;

    descriptor.limit_low  = 0xffff;
    descriptor.limit_high = 0xf;

    descriptor.base_low  = 0;
    descriptor.base_high = 0;

    descriptor.accessed   = 0;
    descriptor.rw         = 1;
    descriptor.dc         = 0;
    descriptor.executable = 0;
    descriptor.always_1   = 1;
    descriptor.privilege  = 0;
    descriptor.present    = 1;
    descriptor.avl        = 0;
    descriptor.long_mode  = 1;
    descriptor.size       = 0;
    descriptor.page       = 1;

    return descriptor;
}

gdt::gdt_descriptor_t gdt_user_code_descriptor() {
    gdt::gdt_descriptor_t descriptor;

    descriptor.limit_low  = 0xffff;
    descriptor.limit_high = 0xf;

    descriptor.base_low  = 0;
    descriptor.base_high = 0;

    descriptor.accessed   = 0;
    descriptor.rw         = 1;
    descriptor.dc         = 0;
    descriptor.executable = 1;
    descriptor.always_1   = 1;
    descriptor.privilege  = 3;
    descriptor.present    = 1;
    descriptor.avl        = 0;
    descriptor.long_mode  = 1;
    descriptor.size       = 0;
    descriptor.page       = 1;

    return descriptor;
}

gdt::gdt_descriptor_t gdt_user_data_descriptor() {
    gdt::gdt_descriptor_t descriptor;

    descriptor.limit_low  = 0xffff;
    descriptor.limit_high = 0xf;

    descriptor.base_low  = 0;
    descriptor.base_high = 0;

    descriptor.accessed   = 0;
    descriptor.rw         = 1;
    descriptor.dc         = 0;
    descriptor.executable = 0;
    descriptor.always_1   = 1;
    descriptor.privilege  = 3;
    descriptor.present    = 1;
    descriptor.avl        = 0;
    descriptor.long_mode  = 1;
    descriptor.size       = 0;
    descriptor.page       = 1;

    return descriptor;
}

gdt::gdt_descriptor_t gdt_tss_descriptor() {
    gdt::gdt_descriptor_t descriptor;

    uint32_t addr = (uint32_t)&tss;
    uint32_t size = sizeof(tss);

    descriptor.limit_low  = size & 0xFFFF; /* Bits 0-15 */
    descriptor.limit_high = (size >> 16) & 0xF; /* Bits 16-19 */

    descriptor.base_low  = addr & 0xFFFFFF;     /* Bits 0-23 */ 
    descriptor.base_high = (addr >> 24) & 0xFF; /* Bits 24-31 */

    descriptor.accessed   = 1;
    descriptor.rw         = 0;
    descriptor.dc         = 0;
    descriptor.executable = 1;
    descriptor.always_1   = 0;
    descriptor.privilege  = 0;
    descriptor.present    = 1;
    descriptor.avl        = 0;
    descriptor.long_mode  = 0;
    descriptor.size       = 1;
    descriptor.page       = 0;

    return descriptor;
}

void setup_idt() {
    static const gdt::gdt_ptr_t null_idt = {0, 0};
    asm volatile("lidt %0" : : "m" (null_idt));
}

void setup_gdt() {
    gdt_array[0] = gdt_null_descriptor();
    gdt_array[1] = gdt_kernel_code_descriptor();
    gdt_array[3] = gdt_kernel_code_descriptor_32();
    gdt_array[2] = gdt_kernel_data_descriptor();
    gdt_array[4] = gdt_user_code_descriptor();
    gdt_array[5] = gdt_user_data_descriptor();
    gdt_array[6] = gdt_tss_descriptor();

    gdt_ptr.size = sizeof(gdt_array) - 1;
    gdt_ptr.offset = (uint32_t)&gdt_array;

    asm volatile("lgdt [%0]" : : "m" (gdt_ptr));
}

void __attribute__ ((noreturn)) kinit16() {
    asm volatile ("cli"); /* Disable interrupts */

    setup_idt();

    setup_gdt();

    /* Enable protected mode */ 
    asm volatile("mov eax, cr0; or al, 1; mov cr0, eax;"); 

    /* Disable paging */
    asm volatile("mov eax, cr0; and eax, 0b01111111111111111111111111111111; mov cr0, eax;");

    /* Jump to kinit32 */
    asm volatile(".byte 0x66, 0xea; .long kinit32; .word 0x8;");

    __builtin_unreachable();
}