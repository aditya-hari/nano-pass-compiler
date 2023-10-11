	.align 8
f141901conclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq

	.align 8
f141901:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	pushq	%rbx
	jmp f141901start

	.align 8
f141901start:
	movq	%rdi, %rbx
	movq	$5, %rdi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax

	.align 8
f41902conclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.align 8
f41902:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	jmp f41902start

	.align 8
f41902start:
	movq	%rdi, %rcx
	movq	%rcx, %rax
	addq	$10, %rax
	jmp f41902conclusion

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
	leaq	f141901(%rip), %rbx
	leaq	f41902(%rip), %rcx
	movq	%rcx, %rdi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax



