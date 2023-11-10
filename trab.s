section .data

    brk_inicial: .quad 0
    brk_atual: .quad 0

section .text

    extern setup_brk

setup_brk:

    pushq %rbp
    movq %rsp, %rbp
    movq $12, %rax   // Número do syscall para brk (12)
    movq $0, %rdi   //  Obter o valor inicial de brk
    syscall         
    movq %rax, brk_inicial // Preserva o valor atual de %rax na pilha
    popq %rbp
    ret

    extern dismiss_brk

dismiss_brk:

    pushq %rbp
    movq %rsp, %rbp
    movq $12, %rax          // Número do syscall para brk (12)
    movq brk_inicial, %rdi  // Passa o valor inicial de brk como argumento
    syscall
    popq %rbp
    ret

    extern memory_alloc

memory_alloc:

    pushq %rbp
    movq %rsp, %rbp
    movq +16(%rbp), %rdi // Pega o tamanho do bloco a ser alocado na pilha

    // Verifica se o brk_atual é igual ao brk_inicial
    cmpq brk_inicial, brk_atual
    je brk_atual_igual_inicial
    jmp brk_atual_diferente_inicial

    brk_atual_igual_inicial:
    addq $8, brk_atual  // aumenta o brk_atual em 8 bytes
    movq brk_atual, %rax // rax = brk_atual
    movq $1, (%rax) // coloca 1 no conteúdo do brk_atual
    addq $8, brk_atual // aumenta o brk_atual em 8 bytes
    movq brk_atual, %rax // rax = brk_atual
    movq %rdi, (%rax) // coloca o tamanho (rdi) no conteúdo do brk_atual
    addq %rdi, brk_atual // aumenta o brk_atual em rdi bytes
    movq brk_atual, %rax // rax = brk_atual
    popq %rbp
    ret

    brk_atual_diferente_inicial:
    
    



    extern memory_free

memory_free:
