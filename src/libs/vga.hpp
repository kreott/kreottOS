#pragma once
#include <stdint.h>

namespace vga 
{
    void clear();
    void putchar(char c);
    void write(const char* str);
    void write_hex(const uint64_t hex);
    void write_dec(const uint32_t dec);
}