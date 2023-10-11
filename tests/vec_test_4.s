	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$40, %rsp
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
	subq	$40, %rsp
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
block41635:
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
	movq	%rbx, %r12
	addq	$16, %r12
	movq	fromspace_end(%rip), %rbx
	cmpq	%rbx, %r12
	jl block41632
	jmp block41633

	.align 8
block41633:
	movq	%r15, %rdi
	movq	$16, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$131, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	-40(%rbp), %rax
	movq	%rax, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	8(%r11), %rax
	jmp mainconclusion

	.align 8
block41634:
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
	movq	%rbx, %r12
	addq	$16, %r12
	movq	fromspace_end(%rip), %rbx
	cmpq	%rbx, %r12
	jl block41632
	jmp block41633

	.align 8
mainstart:
	movq	$42, %rbx
	movq	free_ptr(%rip), %r12
	movq	%r12, %r13
	addq	$16, %r13
	movq	fromspace_end(%rip), %r12
	cmpq	%r12, %r13
	jl block41634
	jmp block41635

	.align 8
block41632:
	movq	free_ptr(%rip), %r11
	addq	$16, free_ptr(%rip)
	movq	$131, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	-40(%rbp), %rax
	movq	%rax, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	movq	%rax, -32(%rbp)
	movq	-32(%rbp), %r11
	movq	8(%r11), %rax
	movq	%rax, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	8(%r11), %rax
	jmp mainconclusion



