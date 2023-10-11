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
loop41468:
	jmp block41469

	.align 8
mainstart:
	jmp loop41468

	.align 8
block41469:
	movq	$5, %rax
	addq	$10, %rax
	jmp mainconclusion



