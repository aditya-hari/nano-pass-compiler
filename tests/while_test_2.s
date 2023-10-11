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
block41452:
	movq	%rdx, %rax
	jmp mainconclusion

	.align 8
block41451:
	movq	%rdx, %rcx
	movq	%rcx, %rdx
	addq	%rsi, %rdx
	movq	$1, %rcx
	negq	%rcx
	addq	%rcx, %rsi
	jmp loop41450

	.align 8
loop41450:
	movq	%rsi, %rcx
	movq	$0, %rax
	cmpq	%rcx, %rax
	jl block41451
	jmp block41452

	.align 8
mainstart:
	movq	$0, %rdx
	movq	$5, %rsi
	jmp loop41450



