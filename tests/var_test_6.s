	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%r13
	popq	%r12
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	pushq	%r12
	pushq	%r13
	pushq	%rbx
	movq	$16384, %rdi
	movq	$16384, %rsi
	callq	initialize
	movq	rootstack_begin(%rip), %r15
	addq	$0, %r15
	jmp mainstart

	.align 8
mainstart:
	movq	$10, %r13
	movq	$15, %r12
	callq	read_int
	movq	%rax, %rbx
	addq	%r12, %rbx
	movq	%rbx, %rax
	addq	%r13, %rax
	jmp mainconclusion



