	.align 8
is1041924conclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq

	.align 8
is1041924:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	pushq	%rbx
	jmp is1041924start

	.align 8
is1041924start:
	movq	%rdi, %rcx
	cmpq	$10, %rcx
	je block41946
	jmp block41947

	.align 8
block41944:
	leaq	is1041924(%rip), %rbx
	addq	$1, %rcx
	movq	%rcx, %rdi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax

	.align 8
block41946:
	movq	%rcx, %rax
	jmp is1041924conclusion

	.align 8
block41945:
	leaq	is1041924(%rip), %rbx
	subq	$1, %rcx
	movq	%rcx, %rdi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax

	.align 8
block41947:
	cmpq	$10, %rcx
	jl block41944
	jmp block41945

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
	leaq	is1041924(%rip), %rbx
	movq	$15, %rdi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax



