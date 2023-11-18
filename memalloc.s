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

    # 1: Atualiza a pilha

    pushq %rbp
    movq %rsp, %rbp

    # Especial: Rbx recebe argumento
    movq %rdi, %rbx

    # 2: Guarda valores nos registradores

    movq brk_inicial, %r13

    
    
    
    
    
    
    # 3: Percorre até achar bloco para alocar
    percorre_brk:

    # 3.1: Compara brk inicial com atual
    cmpq %r13, brk_atual
    # 3.2 Se forem iguais, então heap vazia a partir daí
    je bloco_novo

    # 3.3 Guarda valores dos registradores
    movq (%r13), %r12
    addq $8, %r13
    movq (%r13), %r15
    addq $8, %r13

    # 3.4: verifica se o bloco tá livre
    cmpq $0, %r12
    je bloco_livre

    # 3.5: Percorre bloco de dados
    addq %r15, %r13

    # 3.6: Reseta loop
    jmp percorre_brk

    
    
    
    
    
    
    # Verifica detalhes do bloco
    bloco_livre:

    # 1: Verifica se o tamanho é compatível
    cmpq %rbx, %r15

    # 2: Se o tamanho for maior
    jg bloco_maior

    # 3: Se o tamanho for igual
    je bloco_igual

    # 4: Percorre bloco de dados
    addq %r15, %r13

    # 5: Volta pro loop
    jmp percorre_brk

    
    
    
    
    
    
    # Aloca sem colocar registradores no final
    bloco_igual:

    # 1: Informa que o bloco está ocupado
    subq $16, %r13
    movq $1, (%r13)
    movq (%r13), %r12

    # 2: Volta para o início do bloco de dados
    addq $16, %r13

    # 3: Guarda endereço do bloco de dados
    movq %r13, %rax

    # 4: Percorre bloco de dados
    addq %rbx, %r9

    # 5: Retorna endereço do bloco de dados
    popq %rbp
    ret

    
    
    
    
    # Aloca verificando diferença 
    bloco_maior:

    # 1: Move tamanho do bloco para r11
    movq %r15, %r11

    # 2: Tamanho do bloco - Tamanho passado por argumento
    subq %rbx, %r15

    # 3: Move a diferença para r14
    movq %r15, %r14

    # 4: Tamanho do bloco de volta em r15
    movq %r11, %r15

    # 5: Compara a diferença com 17
    cmp $17, %r14

    # 6: Caso seja maior ou igual que 17
    jge maior_17

    # 7: Se não for maior, alocar bloco sem registradores.

    # 7.1: Marca como ocupado
    subq $16, %r13
    movq $1, (%r13)
    movq (%r13), %r12

    # 7.2: Não atualiza tamanho
    addq $16, %r13

    # 7.3: Início bloco de dados em %rax
    movq %r13, %rax 

    # 7.4: Retorna endereço
    popq %rbp
    ret

    
    
    
    
    # Caso seja maior ou igual a 17
    maior_17:

    # 1: Muda endereço para bloco ocupado
    subq $16, %r13
    movq $1, (%r13)
    movq (%r13), %r12

    # 2: Muda o tamanho no registrador
    addq $8, %r13
    movq %rbx, (%r13)
    movq (%r13), %r15

    # 3: Início bloco de dados
    addq $8, %r13

    # 4: Guarda endereço de bloco em %rax
    movq %r13, %rax

    # 5: Avança bloco de dados
    addq %rbx, %r13

    # 6: Cria registradores

    # 6.1 Registrador com valor livre
    movq $0, (%r13)
    addq $8, %r13

    # 6.2: Diminui 16 do valor que sobra e armazena no registrador
    subq $16, %r14
    movq %r14, (%r13)

    # 7: Retorna endereço
    popq %rbp
    ret

    
    
    
    
    # Primeiro ou ultimo bloco a ser alocado
    bloco_novo:

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
    movq brk_incial, %r13

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
