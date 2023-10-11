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
block41371:
	movq	$3, %rax
	jmp mainconclusion

	.align 8
block41370:
	movq	$2, %rax
	jmp mainconclusion

	.align 8
mainstart:
	movq	$2, %rcx
	movq	$3, %rax
	cmpq	%rcx, %rax
	setl	%al
	movzbq	%al, %rcx
	cmpq	$1, %rcx
	je block41371
	jmp block41370



