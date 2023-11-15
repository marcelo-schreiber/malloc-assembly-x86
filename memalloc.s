.section .bss
	current_brk: .zero	8
	initial_brk: .zero	8

.section .text
	.globl	setup_brk
	.globl	memory_alloc
	.globl	memory_free
	.globl	dismiss_brk
	.globl	initial_brk

setup_brk:
	pushq %rbp
	movq %rsp, %rbp

	movl $0, %edi
	call	sbrk@PLT

	movq	%rax, initial_brk(%rip)	# tmp84, initial_brk

	movl $0, %edi
	call	sbrk@PLT
	movq	%rax, current_brk(%rip)	# tmp85, current_brk

	popq %rbp
	ret	

memory_alloc:
	pushq	%rbp	#
	movq %rsp, %rbp
	pushq	%r12	#
# brk.c:14:     void *current = initial_brk;
	movq	initial_brk(%rip), %rax	# initial_brk, current
# brk.c:13: {
# brk.c:17:     while (current < current_brk)
	movq	current_brk(%rip), %rbp	# current_brk, current_brk.0_11
# brk.c:13: {
	pushq	%rbx	#
# brk.c:13: {
	movq	%rdi, %rbx	# tmp109, bytes

.WHILE_CURRENT_BRK:
# brk.c:17:     while (current < current_brk)
	cmpq	%rax, %rbp	# current, current_brk.0_11
	jle	.OUT_WHILE	#
# brk.c:19:         if (*(unsigned long int *)current == 0 && *(unsigned long int *)(current + 8) >= bytes)
	cmpq	$0, (%rax)	# MEM[(long unsigned int *)current_18]
# brk.c:19:         if (*(unsigned long int *)current == 0 && *(unsigned long int *)(current + 8) >= bytes)
	movq	8(%rax), %rdx	# MEM[(long unsigned int *)current_18 + 8B], pretmp_7
# brk.c:19:         if (*(unsigned long int *)current == 0 && *(unsigned long int *)(current + 8) >= bytes)
	jne	.MAIN_LOOP_INSTRUCTIONS	#
# brk.c:19:         if (*(unsigned long int *)current == 0 && *(unsigned long int *)(current + 8) >= bytes)
	cmpq	%rbx, %rdx	# bytes, pretmp_7
	jb	.MAIN_LOOP_INSTRUCTIONS	#
# brk.c:21:             if (*(unsigned long int *)(current + 8) - bytes >= 16 + 1)
	subq	%rbx, %rdx	# bytes, tmp99
# brk.c:28:                 return current + 16;
	leaq	16(%rax), %r8	# <retval>
# brk.c:21:             if (*(unsigned long int *)(current + 8) - bytes >= 16 + 1)
	cmpq	$16, %rdx	# tmp99
	jle	.ELSE_NOT_ENOUGH_SPACE	#
# brk.c:23:                 void *new_block = current + 16 + bytes;
	leaq	16(%rax,%rbx), %rcx	# new_block
# brk.c:25:                 *(unsigned long int *)(new_block + 8) = *(unsigned long int *)(current + 8) - bytes - 16;
	movq	$-16, %rdx	# tmp102
# brk.c:24:                 *(unsigned long int *)new_block = 0;
	movq	$0, (%rcx)	# MEM[(long unsigned int *)new_block_32]
# brk.c:25:                 *(unsigned long int *)(new_block + 8) = *(unsigned long int *)(current + 8) - bytes - 16;
	subq	%rbx, %rdx	# bytes, tmp101
	addq	8(%rax), %rdx	# MEM[(long unsigned int *)current_18 + 8B], tmp105
# brk.c:25:                 *(unsigned long int *)(new_block + 8) = *(unsigned long int *)(current + 8) - bytes - 16;
	movq	%rdx, 8(%rcx)	# tmp105, MEM[(long unsigned int *)new_block_32 + 8B]
# brk.c:26:                 *(unsigned long int *)current = 1;
	movq	$1, (%rax)	# MEM[(long unsigned int *)current_18]
# brk.c:27:                 *(unsigned long int *)(current + 8) = bytes;
	movq	%rbx, 8(%rax)	# bytes, MEM[(long unsigned int *)current_18 + 8B]
# brk.c:28:                 return current + 16;
	jmp	.FINAL_INSTRUCTIONS	#
.ELSE_NOT_ENOUGH_SPACE:
# brk.c:32:                 *(unsigned long int *)current = 1;
	movq	$1, (%rax)	# MEM[(long unsigned int *)current_18]
# brk.c:33:                 return current + 16;
	jmp	.FINAL_INSTRUCTIONS	#
.MAIN_LOOP_INSTRUCTIONS:
# brk.c:37:         current += *(unsigned long int *)(current + 8) + 16;
	leaq	16(%rax,%rdx), %rax	# current
	jmp	.WHILE_CURRENT_BRK	#
.OUT_WHILE:
# brk.c:47:     return 0;
	movl	$0, %r8d	# <retval>
# brk.c:39:     if (current == current_brk)
	jne	.FINAL_INSTRUCTIONS	#
# brk.c:41:         sbrk(bytes + 16);
	leaq	16(%rbx), %r12	# _13
# brk.c:41:         sbrk(bytes + 16);
	movq	%r12, %rdi	# _13,
	call	sbrk@PLT	#
# brk.c:43:         *(unsigned long int *)(current + 8) = bytes;
	movq	%rbx, 8(%rbp)	# bytes, MEM[(long unsigned int *)current_18 + 8B]
# brk.c:45:         return current + 16;
	leaq	16(%rbp), %r8	# <retval>
# brk.c:42:         *(unsigned long int *)current = 1;
	movq	$1, 0(%rbp)	# MEM[(long unsigned int *)current_18]
# brk.c:44:         current_brk += bytes + 16;
	addq	%r12, current_brk(%rip)	# _13, current_brk
.FINAL_INSTRUCTIONS:
# brk.c:48: };
	popq	%rbx	#
	movq	%r8, %rax	# <retval>,
	popq	%r12	#
	popq	%rbp	#
	ret	

memory_free:
# brk.c:53:     if (pointer == 0)
  pushq %rbp
	movq %rsp, %rbp
	testq	%rdi, %rdi	# pointer
	je	.FINAL_INSTRUCTIONS_EXIT	#
# brk.c:58:     void *max_pointer_val = current_brk - 16;
	movq	current_brk(%rip), %rax	# current_brk, tmp101
	subq	$16, %rax	# max_pointer_val
# brk.c:60:     if (pointer < initial_brk || pointer > max_pointer_val)
	cmpq	%rax, %rdi	# max_pointer_val, pointer
	ja	.FINAL_INSTRUCTIONS_EXIT	#
	cmpq	%rdi, initial_brk(%rip)	# pointer, initial_brk
	ja	.FINAL_INSTRUCTIONS_EXIT	#
# brk.c:66:     *(unsigned long int *)pointer = 0;
	movq	$0, -16(%rdi)	# MEM[(long unsigned int *)pointer_4(D) + -16B]
.FINAL_INSTRUCTIONS_EXIT:
# brk.c:69: };
	xorl	%eax, %eax	#
	popq %rbp
	ret	

dismiss_brk:
	pushq	%rbp	#
	movq %rsp, %rbp
# brk.c:73:     sbrk(initial_brk - current_brk);
	movq	initial_brk(%rip), %rdi	# initial_brk, initial_brk
	subq	current_brk(%rip), %rdi	# current_brk, tmp85
	jmp	sbrk@PLT	#
	popq	%rbp	#
	ret
