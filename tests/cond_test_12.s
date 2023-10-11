	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
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
	movq	%rax, %rbx
	movq	$5, %rax
	cmpq	%rbx, %rax
	jl block41295
	jmp block41294

	.align 8
block41295:
	callq	read_int
	movq	%rax, %rbx
	addq	$5, %rbx
	cmpq	$10, %rbx
	je block41293
	jmp block41294

	.align 8
block41294:
	movq	$10, %rax
	jmp mainconclusion

	.align 8
block41293:
	movq	$5, %rax
	jmp mainconclusion



