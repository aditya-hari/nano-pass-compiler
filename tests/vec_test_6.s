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
mainstart:
	movq	$1, %rbx
	movq	$20, %r14
	movq	$30, %r13
	movq	$40, %r12
	movq	$1, -80(%rbp)
	movq	-56(%rbp), %rax
	movq	%rax, free_ptr(%rip)
	movq	-56(%rbp), %rax
	movq	%rax, -40(%rbp)
	addq	$48, -40(%rbp)
	movq	-48(%rbp), %rax
	movq	%rax, fromspace_end(%rip)
	movq	-48(%rbp), %rax
	cmpq	%rax, -40(%rbp)
	jl block41734
	jmp block41735

	.align 8
block41735:
	movq	%r15, %rdi
	movq	$48, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$48, free_ptr(%rip)
	movq	$11, 0(%r11)
	movq	%r11, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	%r14, 16(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	%r13, 24(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	%r12, 32(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	-80(%rbp), %rax
	movq	%rax, 40(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %rax
	movq	%rax, -72(%rbp)
	callq	read_int
	movq	%rax, %rbx
	movq	-72(%rbp), %r11
	movq	%rbx, 40(%r11)
	movq	-72(%rbp), %r11
	movq	40(%r11), %rbx
	movq	-72(%rbp), %r11
	movq	40(%r11), %r12
	movq	%rbx, %rax
	addq	%r12, %rax
	jmp mainconclusion

	.align 8
block41734:
	movq	free_ptr(%rip), %r11
	addq	$48, free_ptr(%rip)
	movq	$11, 0(%r11)
	movq	%r11, -64(%rbp)
	movq	-64(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	%r14, 16(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	%r13, 24(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	%r12, 32(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %r11
	movq	-80(%rbp), %rax
	movq	%rax, 40(%r11)
	movq	$0, %rbx
	movq	-64(%rbp), %rax
	movq	%rax, -72(%rbp)
	callq	read_int
	movq	%rax, %rbx
	movq	-72(%rbp), %r11
	movq	%rbx, 40(%r11)
	movq	-72(%rbp), %r11
	movq	40(%r11), %rbx
	movq	-72(%rbp), %r11
	movq	40(%r11), %r12
	movq	%rbx, %rax
	addq	%r12, %rax
	jmp mainconclusion



