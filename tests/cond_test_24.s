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
block41356:
	movq	$5, %rax
	jmp mainconclusion

	.align 8
mainstart:
	movq	$5, %rcx
	movq	$6, %rax
	cmpq	%rcx, %rax
	jl block41356
	jmp block41357

	.align 8
block41357:
	movq	$6, %rax
	jmp mainconclusion



