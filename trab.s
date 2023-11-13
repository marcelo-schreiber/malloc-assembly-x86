section .data

    brk_inicial: .quad 0
    brk_atual: .quad 0

section .text

    extern setup_brk

setup_brk:

    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax      // Número do syscall para brk (12)
    movq $0, %rdi       // Passa 0 como argumento para obter o valor inicial de brk
    syscall            // Obtém o valor inicial de brk

    movq %rax, brk_inicial // Preserva o valor inicial de brk na variável global

    popq %rbp
    ret

    extern dismiss_brk

dismiss_brk:

    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax          // Número do syscall para brk (12)
    movq brk_inicial, %rdi  // Passa o valor inicial de brk como argumento
    syscall

    movq %rax, brk_atual // altera o valor de brk_atual

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

    //loop para percorrer os blocos até achar algum que tenha tamanho maior ou igual ao de %rdi
    loop:

    movq brk_inicial, %rax // valor inicial está em %rax
    addq $8, %rax // aumenta o endereço em 8 bytes
    movq (%rax), %rbx // rbx recebe valor livre do bloco
    addq $8, %rax // aumenta o endereço em 8 bytes
    movq (%rax), %rcx // rcx recebe tamanho do bloco

    //compara tamanho com o argumento em rdi, se tamamho for maior ou igual, aloca o bloco
    cmpq %rdi, %rcx
    jg aloca_bloco_maior
    je aloca_bloco_igual

    jump loop

    aloca_bloco_igual:
    addq %rcx, %rax
    addq $8, %rax
    movq $1, (%rax)
    addq $8, %rax
    movq %rdi, (%rax)
    addq %rdi, %rax

    //compara se %rax é o endereço atual de brk
    cmpq brk_atual, %rax
    je fim // se for igual, o bloco é o último

    //se não for o último, retorna o valor do endereço
    subq %rdi, %rax
    subq $16, %rax
    movq %rax, %rdi

    movq $60, %rax
    syscall

    popq %rbp
    ret

    fim:
    // se for o último bloco, brk_atual = rax
    movq %rax, brk_atual
    subq %rdi, %rax
    subq $16, %rax
    movq %rax, %rdi

    movq $60, %rax
    syscall  

    popq %rbp
    ret

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

    aloca_bloco_maior:
    
    
    



    extern memory_free

memory_free:

    pushq %rbp
    movq %rsp, %rbp
    movq +16(%rbp), %rdi // Pega o ponteiro para o bloco a ser liberado na pilha

    //Verifica se o endereço está dentro dos limites do brk
    cmpq brk_inicial, %rdi
    jl endereco_menor_inicial
    cmpq brk_atual, %rdi
    jg endereco_maior_atual

    //se estiver dentro do limite, libera o bloco
    movq brk_inicial, %rax // valor inicial está em %rax

    loop:
    cmpq brk_atual, %rax // compara com o brk atual
    je endereco_nao_encontrado // se for igual o brk atual, o endereço não foi encontrado

    addq $8, %rax // aumenta o endereço em 8 bytes

    //compara endereço com %rdi
    cmpq %rdi, %rax
    je endereco_encontrado // se for igual, o endereço foi encontrado

    addq $8, %rax // aumenta o endereço em 8 bytes
    movq (%rax), %rbx // rbx recebe o tamanho do bloco
    
    addq %rbx, %rax // aumenta o endereço em rbx bytes (pula o bloco)

    jmp loop

    endereco_menor_incial:
    //se for menor retorna zero
    movq $60, %rax
    movq $3, %rdi
    syscall
    popq %rbp
    ret

    endereco_maior_atual:
    //se for maior retorna zero
    movq $60, %rax
    movq $3, %rdi
    syscall
    popq %rbp
    ret

    endereco_nao_encontrado:
    //se não encontrar, retorna 1
    movq $60, %rax
    movq $1, %rdi
    syscall
    popq %rbp
    ret

    endereco_encontrado:
    //verifica se o bloco está livre
    movq (%rax), %rbx // rbx recebe o conteúdo do endereço
    cmpq $0, %rbx // compara com zero
    je bloco_livre // se for igual, o bloco está livre
    movq $0, (%rax) //mudar o valor do bloco para livre
    addq $8, %rax // aumenta o endereço em 8 bytes
    movq (%rax), %rbx // rbx recebe o tamanho do bloco
    addq %rbx, %rax // aumenta o endereço em rbx bytes (pula o bloco)

    //compara se %rax é o endereço atual de brk
    cmpq brk_atual, %rax
    je fim // se for igual, o bloco é o último
    movq $60, %rax
    movq $0, %rdi
    syscall
    popq %rbp
    ret

    bloco_livre:
    //retorna 2
    movq $60, %rax
    movq $2, %rdi
    syscall
    popq %rbp
    ret

    
    fim:
    // se for o último bloco, libera o bloco e diminui o brk
    movq brk_atual, %rbx
    addq $16, %rbx // rbx recebe o brk_atual + 16
    
    movq $12, %rax
    movq brk_atual, %rdi
    subq %rbx, %rdi //diminui o brk em rbx bytes
    syscall

    movq brk_atual, %rbx //atualiza a variavel brk_atual
    popq %rbp
    ret
