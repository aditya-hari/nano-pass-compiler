	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	movq	$16384, %rdi
	movq	$16384, %rsi
	callq	initialize
	movq	rootstack_begin(%rip), %r15
	addq	$0, %r15
	jmp mainstart

	.align 8
mainstart:
	movq	$2, %rcx
	movq	$0, %rdx
	movq	%rdx, %rdi
	movq	%rcx, %rsi
	movq	$40, %rcx
	movq	$10, %rdx
	movq	%rdx, %rcx
	movq	%rcx, %rdx
	movq	%rsi, %rcx
	addq	%rdx, %rcx
	movq	%rdi, %rax
	addq	%rcx, %rax
	jmp mainconclusion



