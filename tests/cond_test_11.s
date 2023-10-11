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
block41276:
	movq	%rbx, %rax
	addq	$2, %rax
	jmp mainconclusion

	.align 8
mainstart:
	callq	read_int
	movq	%rax, %r12
	callq	read_int
	movq	%rax, %rbx
	cmpq	$1, %r12
	jl block41278
	jmp block41279

	.align 8
block41279:
	cmpq	$2, %r12
	je block41276
	jmp block41277

	.align 8
block41278:
	cmpq	$0, %r12
	je block41276
	jmp block41277

	.align 8
block41277:
	movq	%rbx, %rax
	addq	$10, %rax
	jmp mainconclusion



