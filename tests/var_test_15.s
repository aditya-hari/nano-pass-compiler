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
	movq	$17, %rcx
	movq	$8, %rdx
	movq	%rdx, %rsi
	addq	$12, %rsi
	movq	$29, %rdx
	addq	%rsi, %rdx
	movq	%rdx, %rax
	addq	%rcx, %rax
	jmp mainconclusion



