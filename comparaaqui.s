#       MANUAL DE REGISTRADORES
#
#   Argumentos de funções ou syscall: %rdi %rax
#   Guardar tamanho do bloco: %rcx
#   Guardar valor de bloco livre: %rbx
#   Guardar brk_atual: %r8
#   Guardar brk_inicial: %r9
#   Valores de retorno: %rax
#   Registrador temporário: %r10 (valor que sobra), %r11 (valor de rcx)


#       MANUAL DE REGISTRADORES
# Argumentos de funções ou syscall: %rdi %rbx
# Preservados: %rbx, %r12, %r13, %r14, %r15
# Guardar valor de bloco livre: %r12
# Guardar valor de brk_inicial: %r13
# Valores de retorno: %rax
# Guardar valor que sobra do bloco: %r14
# Tamanho do bloco: %r15

.section .data

    PRINT: .string "\n\nendereço = %p\n\n"

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

    movq brk_inicial, %r9
    movq brk_atual, %r8

    # 2: Verifica se o brk_atual é igual ao brk_inicial
    

    # 3: Percorre até achar bloco para alocar
    percorre_brk:

    cmpq %r9, %r8

    je bloco_novo
    
    # 3.3 Guarda valores dos registradores
    movq (%r9), %rbx
    addq $8, %r9
    movq (%r9), %rcx
    addq $8, %r9

    # 3.4: verifica se o bloco tá livre
    cmpq $0, %rbx
    je bloco_livre

    addq %rcx, %r9

    # 3.5: Reseta loop
    jmp percorre_brk

    bloco_livre:

    # 3.6: Verifica se o tamanho é compatível
    cmpq %rdi, %rcx
    jg bloco_maior
    je bloco_igual

    addq %rcx, %r9

    # 3.7: Reseta loop
    jmp percorre_brk


    bloco_igual:

    # 4: Aloca sem colocar registradores no final

    # 4.1: Informa que o bloco está ocupado
    subq $16, %r9
    movq $1, (%r9)
    movq (%r9), %rbx
    
    # 4.2: Volta para o inicio do bloco
    addq $16, %r9

    # 4.3: Guarda endereço do bloco de dados
    movq %r9, %rax

    addq %rdi, %r9

    # 4.6: Retorna endereço do bloco de dados
    popq %rbp
    ret

    bloco_maior:

    # 4.9.1.1: Guarda o tamanho do bloco em %r11
    movq %rcx, %r11

    # 4.9.1.2: Guarda valor do bloco que sobra em %rcx
    subq %rdi, %rcx

    # 4.9.1.3: Guarda valor do bloco que sobra em %r10
    movq %rcx, %r10

    # 4.9.1.4: Guarda tamanho do bloco em %rcx
    movq %r11, %rcx

    cmp $17, %r10

    jge maior_17

    # 4.10: Se não for maior, só aloca e deixa fragmentado.

    # 4.10.1: Marca como bloco ocupado
    subq $16, %r9
    movq $1, (%r9)
    movq (%r9), %rbx

    # 4.10.2: Não atualiza tamanho pq a diferença é menor que 17
    addq $16, %r9

    movq %r9, %rax

    addq %rcx, %r9

    # 4.10.4: Retorna endereço 
    popq %rbp
    ret

    # 4.9: Se for maior
    maior_17:

    # 4.9.2 Muda para bloco ocupado
    subq $16, %r9
    movq $1, (%r9)
    movq (%r9), %rbx

    # 4.9.2: Muda o tamanho no registrador 
    addq $8, %r9
    movq %rdi, (%r9)
    movq (%r9), %rcx

    addq $8, %r9

    # 4.9.3: Guarda endereço de bloco em %rax
    movq %r9, %rax
    
    # 4.9.4: Avança bloco de dados
    addq %rdi, %r9

    # 4.9.5: Cria os dois registradores

    # 4.9.5.1: Registrador com valor livre 0
    movq $0, (%r9)
    addq $8, %r9

    # 4.9.5.2: Diminui 16 do valor que sobra e armazena no registrador
    subq $16, %r10
    movq %r10, (%r9)

    # 4.9.5.3: Registrador de tamanho com tamanho que sobra
    addq $8, %r9
    
    # 4.9.5.3: Avança bloco de dados
    addq %r10, %r9

    # 4.9.7: Retorna endereço 
    popq %rbp
    ret

    bloco_novo:

    addq $16, brk_atual
    addq %rdi, brk_atual

    movq %rdi, %r15

    movq $12, %rax     
    movq brk_atual, %rdi       
    syscall  

    movq %r15, %rdi

    movq $1, (%r8)
    addq $8, %r8
    movq %rdi, (%r8)
    addq $8, %r8

    movq %r8, %rax

    movq brk_atual, %r8
    
    popq %rbp
    ret

memory_free:

    # 1: Atualiza a pilha
    pushq %rbp
    movq %rsp, %rbp

    # 2: Verifica se o valor é maior que 0
    cmpq $0, %rdi
    jg maior_0

    movq $0, %rax
    popq %rbp
    ret

    maior_0:

    # 3: Verfica se o endereço está dentro dos limites do brk

    movq brk_inicial, %r9

    cmpq %r9, %rdi
    jl erro
    
    cmpq %rdi, brk_atual
    jl erro

    # 4: Guarda endereço do brk_inicial
    movq brk_inicial, %r9

    # 5: Loop para achar endereço do bloco
    percorre_brk2:

    movq brk_atual, %r8

    # 5.1: compara brk_atual com inicial para sabermos se estamos no fim
    cmpq %r9, %r8
    je erro

    # 5.2: Avança para registrador de tamanho
    addq $16, %r9

    # 5.3: Guarda tamanho do bloco
    movq (%r9), %rcx

    # 5.4: Avança endereço de dados
    addq %rcx, %r9

    # 5.5: Verifica se achou endereço
    cmpq %rdi, %r9
    je achou_endereco

    jmp percorre_brk2

    achou_endereco:
    # 6: Verifica se o bloco está livre

    # 6.1: Volta para registradores
    subq %rcx, %r9

    # 6.2: Alcança registrador de valor de bloco livre
    subq $16, %r9

    # 6.3: Pega valor do registrador
    movq (%r9), %rbx

    # 6.4: Verifica se está livre
    cmpq $0, %rbx
    je erro

    # 7: Marca bloco como livre
    movq $0, (%r9)

    # 8: Vai até o endereço de dados e verifica se é o ultimo
    addq $8, %r9
    addq %rcx, %r9

    # 8.2 Verifica se é o último

    movq brk_atual, %r8
    cmpq %r9, %r8
    je ultimo

    movq $1, %rax
    popq %rbp
    ret

    ultimo:
    # 9: Atualiza brk_atual
    addq $16, %rcx
    subq %rcx, brk_atual

    movq $12, %rax     
    movq brk_atual, %rdi       
    syscall        

    movq $1, %rax
    popq %rbp
    ret

    erro:
    movq $0, %rax
    popq %rbp
    ret
