#include "kernel.hpp"
#include "../libs/vga.hpp"
#include <stdint.h>

extern "C" void kernel_main() {

    // test THIS WORKS
    volatile uint16_t* vga_buffer = (volatile uint16_t*)0xB8000;
    vga_buffer[0] = 0x0F00 | 'L';


    // this doesnt
    vga::clear();
    
    vga::putchar('B');
    vga::putchar('\n');
    vga::write("Hello, Limine bootloader :3\n");

    while(1) {  }
}
