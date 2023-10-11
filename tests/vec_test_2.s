	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$56, %rsp
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
	subq	$56, %rsp
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
block41547:
	movq	%r15, %rdi
	movq	$16, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -72(%rbp)
	movq	$12, %rbx
	movq	free_ptr(%rip), %r12
	addq	$16, %r12
	movq	fromspace_end(%rip), %r13
	cmpq	%r13, %r12
	jl block41544
	jmp block41545

	.align 8
block41548:
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	$10, %rbx
	movq	free_ptr(%rip), %r12
	addq	$16, %r12
	movq	fromspace_end(%rip), %r13
	cmpq	%r13, %r12
	jl block41546
	jmp block41547

	.align 8
block41545:
	movq	%r15, %rdi
	movq	$16, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -32(%rbp)
	movq	-32(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-32(%rbp), %rax
	movq	%rax, -72(%rbp)
	movq	-72(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	8(%r11), %rbx
	movq	-40(%rbp), %r11
	movq	8(%r11), %r12
	movq	%rbx, %rax
	addq	%r12, %rax
	jmp mainconclusion

	.align 8
block41546:
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -72(%rbp)
	movq	$12, %rbx
	movq	free_ptr(%rip), %r12
	addq	$16, %r12
	movq	fromspace_end(%rip), %r13
	cmpq	%r13, %r12
	jl block41544
	jmp block41545

	.align 8
mainstart:
	movq	$30, %rbx
	movq	free_ptr(%rip), %r12
	addq	$16, %r12
	movq	fromspace_end(%rip), %r13
	cmpq	%r13, %r12
	jl block41548
	jmp block41549

	.align 8
block41544:
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -32(%rbp)
	movq	-32(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-32(%rbp), %rax
	movq	%rax, -72(%rbp)
	movq	-72(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	8(%r11), %rbx
	movq	-40(%rbp), %r11
	movq	8(%r11), %r12
	movq	%rbx, %rax
	addq	%r12, %rax
	jmp mainconclusion

	.align 8
block41549:
	movq	%r15, %rdi
	movq	$16, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$3, 0(%r11)
	movq	%r11, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	$10, %rbx
	movq	free_ptr(%rip), %r12
	addq	$16, %r12
	movq	fromspace_end(%rip), %r13
	cmpq	%r13, %r12
	jl block41546
	jmp block41547



