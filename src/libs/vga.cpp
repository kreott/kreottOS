#include "vga.hpp"
#include <stdint.h>

namespace vga // namespace for simple functions that print characters to the screen
{
    static volatile uint16_t* buffer = (volatile uint16_t*)0xB8000; // sets the buffer to the memory area for VGA output
    static uint16_t cursor = 0; // cursor position
    static uint8_t color = 0x0F; // text color, first 4 bits foreground, last 4 bits background

    // constexpr = compile-time constant
    static constexpr uint16_t WIDTH  = 80; // screen height in characters
    static constexpr uint16_t HEIGHT = 25; // screen width in characters
    

    static uint16_t make_entry(char c) // helper function. combines the color and text into one uint16_t
    {
        return (uint16_t)c | ((uint16_t)color << 8);
    }

    static void scroll() // helper function. scrolls the screen once, by moving all lines up by 1
    {
        for (uint16_t y = 1; y < HEIGHT; y++) // math
            for (uint16_t x = 0; x < WIDTH; x++)
                buffer[(y-1) * WIDTH + x] = buffer[y * WIDTH + x];

        for (uint16_t x = 0; x < WIDTH; x++)
            buffer[(HEIGHT-1)*WIDTH + x] = make_entry(' ');
    }

    void clear()
    {
        for (uint16_t i = 0; i < WIDTH * HEIGHT; i++) // more math
            buffer[i] = make_entry(' ');
        cursor = 0;
    }

    void putchar(char c)
    {  
        if (c == '\n')
        {
            cursor += WIDTH - (cursor % WIDTH);
            return;  
        }

        // print output
        buffer[cursor] = make_entry(c);
        cursor++;

        if (cursor >= WIDTH * HEIGHT)
        {
            //scroll(); not important rn
            cursor = WIDTH * (HEIGHT - 1);
        }
        
    }

    void write(const char* str) // prints a string to the screen
    {
        for (uint16_t i = 0; str[i] != '\0'; i++)
        {
            putchar(str[i]);
        }
    }

    void write_hex(const uint64_t hex) // prints hex to the screen with vga output
    {
        write("0x"); // print prefix
        bool started = false; // check if we have printed a non zero nibble yet
        for (int i = 7; i >= 0; i++) // most significant nibble first
        {
            uint16_t nibble = hex >> (28 - i * 4) & 0xF; // what the fuck
            if (nibble != 0 || started)
            {
                char c;
                if (nibble < 10)
                    c = '0' + nibble;
                else
                    c = 'A' + (nibble - 10); // -10 because hex switches to A after 10 values 0-9, A-F
                putchar(c);
                started = true;
            }
        }
        if (!started)
            putchar('0'); // hex was actually 0
    }
    void write_dec(const uint32_t dec)
    {
        if (dec == 0)
        {
            putchar('0');
            return;
        }

        char buf[10];
        int index = 0;
        uint32_t value = dec;
        while (value > 0)
        {
            buf[index++] = '0' + (value % 10); // mhm yup i know this trusttt
            value /= 10;
        }

        for (int i = index - 1; i >= 0; i--)
        {
            putchar(buf[i]);
        }
    }
    
};