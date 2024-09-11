.section .text

.globl kmain
kmain:
    // Enable SSE and SSE2 since we compile with support for that.
    mov %cr0, %rax
    btrq $2, %rax
    btsq $1, %rax
    mov %rax, %cr0
    mov %cr4, %rax
    btsq $9, %rax
    btsq $10, %rax
    mov %rax, %cr4

    // Jump to V code.
    call main__kmain
