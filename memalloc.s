#       MANUAL DE REGISTRADORES
# Argumentos de funções ou syscall: %rdi %rbx
# Preservados: %rbx, %r12, %r13, %r14, %r15
# Guardar valor de bloco livre: %r12
# Guardar valor de brk_inicial: %r13
# Valores de retorno: %rax
# Guardar valor que sobra do bloco: %r14
# Tamanho do bloco: %r15

.section .data

    .global brk_inicial 
    brk_inicial: .quad 0
    
    .global brk_atual 
    brk_atual: .quad 0

.section .text

    .global setup_brk
    .global dismiss_brk
    .global memory_alloc
    .global memory_free

    
    
    
    
    
    
setup_brk:

    # 1: Atualiza a pilha

    pushq %rbp
    movq %rsp, %rbp

    # 2: Chama syscall com brk (12) e argumento 0
    movq $12, %rax      
    movq $0, %rdi  
    syscall            

    # 3: Atualiza o valor de brk_inicial e brk_atual

    movq %rax, brk_inicial 
    movq %rax, brk_atual 

    # 4: Restaura a pilha
    popq %rbp
    ret

    
    
    
    
    
    
dismiss_brk:

    # 1: Atualiza a pilha
    pushq %rbp
    movq %rsp, %rbp

    # 2: Chama syscall com brk (12) e argumento brk_inicial

    movq $12, %rax         
    movq brk_inicial, %rdi  
    syscall

    # 3: Atualiza o valor de brk_atual

    movq %rax, brk_atual 

    popq %rbp
    ret

    
    
    
    
    
    
memory_alloc:

    # 1: Atualiza Pilha

    pushq %rbp
    movq %rsp, %rbp

    # 2: Rbx recebe argumento
    movq %rdi, %rbx

    # 3: Guarda valores nos registradores

    movq brk_inicial, %r13
    movq $0, %rcx

    # 4: Percorre brk até achar o maior tamanho de bloco livre
    percorre_brk:

    # 1: Compara brk inicial com brk atual
    cmpq %r13, brk_atual
    
    # 2: Se for igual, cria um novo bloco
    je bloco_novo

    # 3: Guarda valores dos registradores
    movq (%r13), %r12
    addq $8, %r13
    movq (%r13), %r15
    addq $8, %r13

    # 4: Compara se o bloco está livre
    cmpq $0, %r12
    je verifica_tamanho

    continua_loop:

    addq %r15, %r13

    jmp percorre_brk

    



    verifica_tamanho:
    //compara tamanho do bloco com %rcx
    cmpq %rcx, %r15

    //se for %r15 for menor, volta para percorre_brk
    jl continua_loop

    //se for %r15 for maior, %rcx recebe %r15
    movq %r15, %rcx
    
    //move endereço do bloco para %r14
    movq %r13, %r14

    jmp continua_loop


    bloco_novo:

    //se o valor de %rcx for zero
    cmpq $0, %rcx
    je cria_bloco

    // faz a diferença entre o tamanho do bloco e o tamanho pedido
    subq %rbx, %rcx

    // se a diferença for maior que 17
    cmpq $17, %rcx
    jge maior_17

    # 7: Se não for maior, alocar bloco sem registradores.

    # 7.1: Marca como ocupado
    subq $16, %r14
    movq $1, (%r14)
    movq (%r14), %r12

    # 7.2: Não atualiza tamanho
    addq $16, %r14

    # 7.3: Início bloco de dados em %rax
    movq %r14, %rax 

    # 7.4: Retorna endereço
    popq %rbp
    ret

    
    # Caso seja maior ou igual a 17
    maior_17:

    # 1: Muda endereço para bloco ocupado
    subq $16, %r14
    movq $1, (%r14)
    movq (%r14), %r12

    # 2: Muda o tamanho no registrador
    addq $8, %r14
    movq %rbx, (%r14)
    movq (%r14), %r15

    # 3: Início bloco de dados
    addq $8, %r14

    # 4: Guarda endereço de bloco em %rax
    movq %r14, %rax

    # 5: Avança bloco de dados
    addq %rbx, %r14

    # 6: Cria registradores

    # 6.1 Registrador com valor livre
    movq $0, (%r14)
    addq $8, %r14

    # 6.2: Diminui 16 do valor que sobra e armazena no registrador
    subq $16, %rcx
    movq %r14, (%r14)

    # 7: Retorna endereço
    popq %rbp
    ret




    cria_bloco:

    # 1: Mudança no brk_atual
    addq $16, brk_atual
    addq %rbx, brk_atual

    # 2: Atualiza brk
    movq $12, %rax
    movq brk_atual, %rdi
    syscall

    # 3: Cria registradores

    # 3.1: Registrador de valor livre
    movq $1, (%r13)
    addq $8, %r13
    
    # 3.2: Registrador de tamanho
    movq %rbx, (%r13)
    addq $8, %r13

    # 4: Guarda início do bloco em %rax
    movq %r13, %rax

    popq %rbp
    ret
    
memory_free:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rbx
    movq brk_inicial, %r13

    cmpq $0, %rbx
    je .RETORNO_FREE

    cmpq brk_atual, %rbx
    jg .RETORNO_FREE

    cmpq brk_inicial, %rbx
    jl .RETORNO_FREE

    subq $16, %rbx

    cmpq brk_atual, %rbx
    jg .RETORNO_FREE

    cmpq brk_inicial, %rbx
    jl .RETORNO_FREE

    addq $16, %rbx

    movq -16(%rbx), %r12

    cmpq $0, %r12
    je .RETORNO_FREE

    cmpq $1, %r12
    je .CORRETO_FREE

	
.RETORNO_FREE:

    popq %rbp
    ret	

.CORRETO_FREE:
    
    movq $0, -16(%rdi)	
    popq %rbp
    ret	
