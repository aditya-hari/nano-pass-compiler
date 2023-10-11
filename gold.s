	.align 16
conclusion:
	addq	$0, %rsp
	popq	%r12
	popq	%rbp
	retq

	.globl main
	.align 16
main:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r12
	subq	$8, %rsp
	jmp start

	.align 16
start:
	callq	read_int
	movq	%rax, %rcx
	movq	%rcx, %r12
	addq	$1, %r12
	callq	read_int
	movq	%rax, %rcx
	addq	$1, %rcx
	movq	%r12, %rax
	addq	%rcx, %rax

	jmp conclusion



