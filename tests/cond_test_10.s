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
block41260:
	movq	$1, %rax
	jmp mainconclusion

	.align 8
mainstart:
	callq	read_int
	movq	%rax, %rbx
	cmpq	$0, %rbx
	je block41262
	jmp block41261

	.align 8
block41262:
	callq	read_int
	movq	%rax, %rbx
	cmpq	$1, %rbx
	je block41260
	jmp block41261

	.align 8
block41261:
	movq	$42, %rax
	jmp mainconclusion



