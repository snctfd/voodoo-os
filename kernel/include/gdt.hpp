/*
 * --------------------------------------------------
 * File: gdt.hpp
 * Date: 2018-07-06
 * Author: snctfd (Rasmus Beck)
 * 
 * Provides definitions necessary for the GDT to
 * function properly.
 * 
 * --------------------------------------------------
 */

#ifndef GDT_HPP
#define GDT_HPP

#include <stdint.hpp>

namespace gdt {
    struct gdt_descriptor_t {
        unsigned int limit_low  : 16;
        unsigned int base_low   : 24;
        unsigned int accessed   : 1;
        unsigned int rw         : 1;
        unsigned int dc         : 1;
        unsigned int executable : 1;
        unsigned int always_1   : 1;
        unsigned int privilege  : 2;
        unsigned int present    : 1;
        unsigned int limit_high : 4;
        unsigned int avl        : 1;
        unsigned int long_mode  : 1;
        unsigned int size       : 1;
        unsigned int page       : 1;
        unsigned int base_high  : 8;
    } __attribute__((packed));

    struct gdt_ptr_t {
        unsigned int size   : 16;
        unsigned int offset : 32;
    } __attribute__((packed));

    struct tss_t {
        uint32_t reserved_0;
        uint64_t rsp0;
        uint64_t rsp1;
        uint64_t rsp2;
        uint64_t reserved_1;
        uint64_t ist1;
        uint64_t ist2;
        uint64_t ist3;
        uint64_t ist4;
        uint64_t ist5;
        uint64_t ist6;
        uint64_t ist7;
        uint64_t reserved_2;
        uint16_t reserved_3;
        uint16_t iopb_offset;
    };
}

#endif /* GDT_HPP */
