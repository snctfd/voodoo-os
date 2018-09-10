#ifndef STDINT_HPP
#define STDINT_HPP

typedef   signed int  int8_t __attribute__((__mode__(__QI__)));
typedef unsigned int uint8_t __attribute__((__mode__(__QI__)));

typedef   signed int  int16_t __attribute__((__mode__(__HI__)));
typedef unsigned int uint16_t __attribute__((__mode__(__HI__)));

typedef   signed int  int32_t __attribute__((__mode__(__SI__)));
typedef unsigned int uint32_t __attribute__((__mode__(__SI__)));

typedef   signed int  int64_t __attribute__((__mode__(__DI__)));
typedef unsigned int uint64_t __attribute__((__mode__(__DI__)));

#endif /* STDINT_HPP */
