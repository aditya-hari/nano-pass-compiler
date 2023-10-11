	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$48, %rsp
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
	subq	$48, %rsp
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
block41601:
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-48(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	free_ptr(%rip), %rbx
	movq	%rbx, %r14
	addq	$32, %r14
	movq	fromspace_end(%rip), %rbx
	cmpq	%rbx, %r14
	jl block41599
	jmp block41600

	.align 8
block41602:
	movq	%r15, %rdi
	movq	$16, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-48(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	free_ptr(%rip), %rbx
	movq	%rbx, %r14
	addq	$32, %r14
	movq	fromspace_end(%rip), %rbx
	cmpq	%rbx, %r14
	jl block41599
	jmp block41600

	.align 8
mainstart:
	movq	$40, %r13
	movq	$1, %r12
	movq	$2, %rbx
	movq	free_ptr(%rip), %r14
	addq	$16, %r14
	movq	-80(%rbp), %rax
	movq	%rax, fromspace_end(%rip)
	cmpq	-80(%rbp), %r14
	jl block41601
	jmp block41602

	.align 8
block41599:
	movq	free_ptr(%rip), %r11
	addq	$32, free_ptr(%rip)
	movq	$519, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%r13, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	%r12, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	-40(%rbp), %rax
	movq	%rax, 24(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	$1, %rax
	cmpq	16(%r11), %rax
	je block41597
	jmp block41598

	.align 8
block41600:
	movq	%r15, %rdi
	movq	$32, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$32, free_ptr(%rip)
	movq	$519, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%r13, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	%r12, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	-40(%rbp), %rax
	movq	%rax, 24(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	$1, %rax
	cmpq	16(%r11), %rax
	je block41597
	jmp block41598

	.align 8
block41597:
	movq	-64(%rbp), %r11
	movq	8(%r11), %rbx
	movq	-64(%rbp), %r11
	movq	24(%r11), %rax
	movq	%rax, -72(%rbp)
	movq	-72(%rbp), %r11
	movq	8(%r11), %r12
	movq	%rbx, %rax
	addq	%r12, %rax
	jmp mainconclusion

	.align 8
block41598:
	movq	$44, %rax
	jmp mainconclusion



