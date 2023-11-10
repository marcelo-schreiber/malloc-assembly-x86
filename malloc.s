section .data
	initial_brk: .quad 0

section	.text
	.p2align 4
	.globl	setup_brk
	.type	setup_brk, @function
setup_brk:
.LFB0:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	xorl	%edi, %edi
	call	sbrk@PLT
	xorl	%edi, %edi
	movq	%rax, initial_brk(%rip)
	call	sbrk@PLT
	movq	%rax, current_brk(%rip)
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	setup_brk, .-setup_brk
	.p2align 4
	.globl	memory_alloc
	.type	memory_alloc, @function
memory_alloc:
.LFB1:
	.cfi_startproc
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	movq	initial_brk(%rip), %rax
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	movq	%rdi, %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	movq	current_brk(%rip), %rbx
	cmpq	%rbx, %rax
	jnb	.L5
	.p2align 4,,10
	.p2align 3
.L9:
	cmpq	$0, (%rax)
	movq	8(%rax), %rdx
	jne	.L6
	cmpq	%rbp, %rdx
	jnb	.L13
.L6:
	leaq	16(%rax,%rdx), %rax
	cmpq	%rax, %rbx
	ja	.L9
.L5:
	xorl	%r8d, %r8d
	cmpq	%rax, %rbx
	je	.L14
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	movq	%r8, %rax
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L13:
	.cfi_restore_state
	subq	%rbp, %rdx
	leaq	16(%rax), %r8
	cmpq	$16, %rdx
	jbe	.L7
	leaq	16(%rax,%rbp), %rcx
	movq	$-16, %rdx
	movq	$0, (%rcx)
	subq	%rbp, %rdx
	addq	8(%rax), %rdx
	movq	%rdx, 8(%rcx)
	movq	$1, (%rax)
	movq	%rbp, 8(%rax)
	movq	%r8, %rax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L7:
	.cfi_restore_state
	movq	$1, (%rax)
	movq	%r8, %rax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L14:
	.cfi_restore_state
	leaq	16(%rbp), %r12
	movq	%r12, %rdi
	call	sbrk@PLT
	leaq	16(%rbx), %r8
	movq	$1, (%rbx)
	movq	%rbp, 8(%rbx)
	movq	%r8, %rax
	popq	%rbx
	.cfi_def_cfa_offset 24
	addq	%r12, current_brk(%rip)
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE1:
	.size	memory_alloc, .-memory_alloc
	.p2align 4
	.globl	memory_free
	.type	memory_free, @function
memory_free:
.LFB2:
	.cfi_startproc
	testq	%rdi, %rdi
	je	.L16
	movq	current_brk(%rip), %rax
	subq	$16, %rax
	cmpq	%rax, %rdi
	ja	.L16
	cmpq	%rdi, initial_brk(%rip)
	ja	.L16
	movq	$0, -16(%rdi)
.L16:
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE2:
	.size	memory_free, .-memory_free
	.p2align 4
	.globl	dismiss_brk
	.type	dismiss_brk, @function
dismiss_brk:
.LFB3:
	.cfi_startproc
	movq	initial_brk(%rip), %rdi
	subq	current_brk(%rip), %rdi
	jmp	sbrk@PLT
	.cfi_endproc
.LFE3:
	.size	dismiss_brk, .-dismiss_brk
	.globl	current_brk
	.bss
	.align 8
	.type	current_brk, @object
	.size	current_brk, 8
current_brk:
	.zero	8
	.globl	initial_brk
	.align 8
	.type	initial_brk, @object
	.size	initial_brk, 8