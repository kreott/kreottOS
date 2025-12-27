OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

SECTIONS
{
    . = 1M;  /* load kernel at 1 MB */
    .multiboot : { *(.multiboot) }
    .text : { *(.text) }
    .rodata : { *(.rodata) }
    .data : { *(.data) }
    
    .bss : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
    }
}
