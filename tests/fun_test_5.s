	.align 8
add41914conclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.align 8
add41914:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	jmp add41914start

	.align 8
add41914start:
	movq	%rdi, %rdx
	movq	%rsi, %rcx
	movq	%rdx, %rax
	addq	%rcx, %rax
	jmp add41914conclusion

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
	leaq	add41914(%rip), %rbx
	movq	$5, %rdi
	movq	$6, %rsi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax



