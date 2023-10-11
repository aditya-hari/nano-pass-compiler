	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%r13
	popq	%r12
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	pushq	%r12
	pushq	%r13
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
	movq	$0, %r13
	jmp loop41477

	.align 8
block41479:
	movq	%r13, %rax
	jmp mainconclusion

	.align 8
block41478:
	movq	%r13, %rbx
	movq	$1, %r13
	addq	%rbx, %r13
	jmp loop41477

	.align 8
loop41477:
	movq	%r13, %rbx
	cmpq	%r12, %rbx
	jl block41478
	jmp block41479



