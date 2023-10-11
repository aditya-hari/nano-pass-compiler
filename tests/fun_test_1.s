	.align 8
id41783conclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.align 8
id41783:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	jmp id41783start

	.align 8
id41783start:
	movq	%r8, %rcx
	movq	%r9, %rcx
	movq	%rdi, %rax
	jmp id41783conclusion

	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$32, %rsp
	popq	%rbx
	popq	%r13
	popq	%r12
	popq	%r14
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	pushq	%r14
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
	leaq	id41783(%rip), %r12
	movq	$0, %r13
	movq	$42, %rbx
	movq	free_ptr(%rip), %r14
	movq	%r14, -48(%rbp)
	addq	$24, -48(%rbp)
	movq	fromspace_end(%rip), %r14
	cmpq	%r14, -48(%rbp)
	jl block41818
	jmp block41819

	.align 8
block41818:
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%r13, 8(%r11)
	movq	$0, %r13
	movq	-56(%rbp), %r11
	movq	%rbx, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	$42, %rdi
	movq	$42, %rsi
	movq	$42, %rdx
	movq	$42, %rcx
	movq	$42, %r8
	movq	-40(%rbp), %r9
	movq	%r12, %rax
	subq	$0, %r15
	addq	$32, %rsp
	popq	%rbx
	popq	%r13
	popq	%r12
	popq	%r14
	popq	%rbp
	jmp *%rax

	.align 8
block41819:
	movq	%r15, %rdi
	movq	$24, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%r13, 8(%r11)
	movq	$0, %r13
	movq	-56(%rbp), %r11
	movq	%rbx, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	$42, %rdi
	movq	$42, %rsi
	movq	$42, %rdx
	movq	$42, %rcx
	movq	$42, %r8
	movq	-40(%rbp), %r9
	movq	%r12, %rax
	subq	$0, %r15
	addq	$32, %rsp
	popq	%rbx
	popq	%r13
	popq	%r12
	popq	%r14
	popq	%rbp
	jmp *%rax



