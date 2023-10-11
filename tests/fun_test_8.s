	.align 8
multiply41984conclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.align 8
multiply41984:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	jmp multiply41984start

	.align 8
multiply41984start:
	movq	%rdi, %rcx
	movq	%rcx, %rdx
	jmp loop42002

	.align 8
loop42002:
	movq	%rsi, %rcx
	movq	$1, %rax
	cmpq	%rcx, %rax
	jl block42003
	jmp block42004

	.align 8
block42004:
	movq	%rdx, %rax
	jmp multiply41984conclusion

	.align 8
block42003:
	addq	%rcx, %rdx
	movq	%rsi, %rcx
	movq	$1, %rdi
	negq	%rdi
	movq	%rcx, %rsi
	addq	%rdi, %rsi
	jmp loop42002

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
	leaq	multiply41984(%rip), %rbx
	movq	$2, %rdi
	movq	$3, %rsi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax



