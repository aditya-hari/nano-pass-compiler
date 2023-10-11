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
block41683:
	movq	-80(%rbp), %r11
	movq	8(%r11), %rbx
	movq	-80(%rbp), %r11
	movq	24(%r11), %rax
	movq	%rax, -72(%rbp)
	movq	-72(%rbp), %r11
	movq	8(%r11), %r12
	movq	%rbx, %rax
	addq	%r12, %rax
	jmp mainconclusion

	.align 8
block41684:
	movq	$44, %rax
	jmp mainconclusion

	.align 8
mainstart:
	movq	$40, %r13
	movq	$1, %rbx
	movq	$2, %r12
	movq	free_ptr(%rip), %r14
	addq	$16, %r14
	movq	-64(%rbp), %rax
	movq	%rax, fromspace_end(%rip)
	cmpq	-64(%rbp), %r14
	jl block41687
	jmp block41688

	.align 8
block41687:
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	%r12, 8(%r11)
	movq	$0, %r12
	movq	-48(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	free_ptr(%rip), %r12
	addq	$32, %r12
	movq	fromspace_end(%rip), %r14
	cmpq	%r14, %r12
	jl block41685
	jmp block41686

	.align 8
block41688:
	movq	%r15, %rdi
	movq	$16, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	%r12, 8(%r11)
	movq	$0, %r12
	movq	-48(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	free_ptr(%rip), %r12
	addq	$32, %r12
	movq	fromspace_end(%rip), %r14
	cmpq	%r14, %r12
	jl block41685
	jmp block41686

	.align 8
block41685:
	movq	free_ptr(%rip), %r11
	addq	$32, free_ptr(%rip)
	movq	$519, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%r13, 8(%r11)
	movq	$0, %r12
	movq	-56(%rbp), %r11
	movq	%rbx, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	-40(%rbp), %rax
	movq	%rax, 24(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -80(%rbp)
	movq	-80(%rbp), %r11
	movq	$1, %rax
	cmpq	16(%r11), %rax
	je block41683
	jmp block41684

	.align 8
block41686:
	movq	%r15, %rdi
	movq	$32, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$32, free_ptr(%rip)
	movq	$519, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%r13, 8(%r11)
	movq	$0, %r12
	movq	-56(%rbp), %r11
	movq	%rbx, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	-40(%rbp), %rax
	movq	%rax, 24(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -80(%rbp)
	movq	-80(%rbp), %r11
	movq	$1, %rax
	cmpq	16(%r11), %rax
	je block41683
	jmp block41684



