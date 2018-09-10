/*
 * --------------------------------------------------
 * File: boot.hpp
 * Date: 2018-09-10
 * Author: snctfd (Rasmus Beck)
 * --------------------------------------------------
 */

#ifndef BOOT_HPP
#define BOOT_HPP

extern "C" {
    void __attribute__((noreturn)) kinit32();
}
#endif /* BOOT_HPP */
