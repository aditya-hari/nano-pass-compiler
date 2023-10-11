	.align 8
f41883conclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.align 8
f41883:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	jmp f41883start

	.align 8
f41883start:
	movq	%r8, %rcx
	movq	%r9, %rdx
	movq	$42, %rdx
	movq	$10, %rcx
	movq	%rcx, %rsi
	movq	%rdx, %rcx
	movq	%rsi, %rdx
	addq	%rcx, %rdx
	movq	%rdx, %rax
	jmp f41883conclusion

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
	leaq	f41883(%rip), %rbx
	movq	$0, %rdi
	movq	$0, %rsi
	movq	$0, %rdx
	movq	$0, %rcx
	movq	$0, %r8
	movq	$0, %r9
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax



