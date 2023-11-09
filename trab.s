section .data

    original_brk: .quad 0

section .text

    extern setup_brk

setup_brk:
    movq $12, %rax   // Número do syscall para brk (12)
    movq $0, %rdi   // Passa 0 como argumento para obter o valor inicial de brk
    syscall         
    movq %rax, original_brk // Preserva o valor atual de %rax na pilha
    ret

    extern atual_brk

atual_brk:
    movq $12, %rax
    movq $0, %rdi
    syscall
    movq %rax, %rbx
    ret

    extern dismiss_brk

dismiss_brk:

    movq original_brk, %rax // pega valor inicial de brk
    call atual_brk          // pega valor atual de brk
    cmp %rbx, %rax          // verifica se são iguais
    je _iguais              // se forem iguais pula para _iguais

    movq %rbp, %rcx
    subq $16, %rcx
    pushq $rcx







    _iguais:                // retorna 0 se são iguais
    movq $60, %rax          
    movq $0, %rdi
    syscall



    extern memory_alloc

memory_alloc:

    extern memory_free

memory_free:
