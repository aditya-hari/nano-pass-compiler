	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbx
	popq	%r12
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	pushq	%r12
	pushq	%rbx
	movq	$16384, %rdi
	movq	$16384, %rsi
	callq	initialize
	movq	rootstack_begin(%rip), %r15
	addq	$0, %r15
	jmp mainstart

	.align 8
mainstart:
	callq	read_int
	movq	%rax, %r12
	movq	$5, %rbx
	negq	%rbx
	addq	$10, %rbx
	movq	%rbx, %rax
	addq	%r12, %rax
	jmp mainconclusion



