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
block41324:
	movq	$6, %rax
	jmp mainconclusion

	.align 8
block41323:
	movq	$5, %rax
	jmp mainconclusion

	.align 8
mainstart:
	movq	$1, %rcx
	movq	$2, %rax
	cmpq	%rcx, %rax
	jl block41323
	jmp block41325

	.align 8
block41325:
	movq	$2, %rcx
	movq	$1, %rax
	cmpq	%rcx, %rax
	jl block41323
	jmp block41324



