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
block41782:
	movq	%r15, %rdi
	movq	$48, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$48, free_ptr(%rip)
	movq	$11, 0(%r11)
	movq	%r11, -40(%rbp)
	movq	-40(%rbp), %r11
	movq	-64(%rbp), %rax
	movq	%rax, 8(%r11)
	movq	$0, %r14
	movq	-40(%rbp), %r11
	movq	%rbx, 16(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	%r13, 24(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	%r12, 32(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	-56(%rbp), %rax
	movq	%rax, 40(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	0(%r11), %rax
	sarq	$1, %rax
	andq	$63, %rax
	movq	%rax, %r12
	callq	read_int
	movq	%rax, %rbx
	cmpq	%r12, %rbx
	jl block41779
	jmp block41780

	.align 8
block41781:
	movq	free_ptr(%rip), %r11
	addq	$48, free_ptr(%rip)
	movq	$11, 0(%r11)
	movq	%r11, -40(%rbp)
	movq	-40(%rbp), %r11
	movq	-64(%rbp), %rax
	movq	%rax, 8(%r11)
	movq	$0, %r14
	movq	-40(%rbp), %r11
	movq	%rbx, 16(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	%r13, 24(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	%r12, 32(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	-56(%rbp), %rax
	movq	%rax, 40(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	0(%r11), %rax
	sarq	$1, %rax
	andq	$63, %rax
	movq	%rax, %r12
	callq	read_int
	movq	%rax, %rbx
	cmpq	%r12, %rbx
	jl block41779
	jmp block41780

	.align 8
mainstart:
	movq	$1, -64(%rbp)
	movq	$20, %rbx
	movq	$30, %r13
	movq	$40, %r12
	movq	$1, -56(%rbp)
	movq	free_ptr(%rip), %r14
	movq	%r14, -72(%rbp)
	addq	$48, -72(%rbp)
	movq	fromspace_end(%rip), %r14
	cmpq	%r14, -72(%rbp)
	jl block41781
	jmp block41782

	.align 8
block41780:
	movq	-48(%rbp), %r11
	movq	16(%r11), %rax
	jmp mainconclusion

	.align 8
block41779:
	movq	-48(%rbp), %r11
	movq	24(%r11), %rax
	jmp mainconclusion



