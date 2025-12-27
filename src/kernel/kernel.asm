[BITS 64]
global _start
extern kernel_main
extern __bss_start
extern __bss_end

section .multiboot
align 8
multiboot_header:
    dd 0xE85250D6        ; magic
    dd 0                  ; architecture (0 = i386, works for 64-bit too)
    dd header_end - multiboot_header
    dd -(0xE85250D6 + 0 + (header_end - multiboot_header))
header_end:

section .text
_start:
    ; setup stack
    lea rsp, [rel stack_space + 32768]

    ; zero BSS
    mov rdi, __bss_start
    mov rcx, __bss_end
    sub rcx, rdi
    xor rax, rax
    rep stosb

    ; call your C++ kernel entry
    call kernel_main

hang:
    cli
    hlt
    jmp hang

section .bss
align 16
stack_space: resb 32768
