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
block41340:
	movq	%r12, %rax
	addq	$5, %rax
	jmp mainconclusion

	.align 8
mainstart:
	callq	read_int
	movq	%rax, %r12
	callq	read_int
	movq	%rax, %rbx
	movq	$15, %rax
	cmpq	%rbx, %rax
	jl block41340
	jmp block41341

	.align 8
block41341:
	movq	%r12, %rax
	jmp mainconclusion



