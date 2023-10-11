	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$16, %rsp
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
	subq	$16, %rsp
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
block41499:
	movq	%r15, %rdi
	movq	$24, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -40(%rbp)
	movq	-40(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	%r12, 16(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	$42, %rax
	jmp mainconclusion

	.align 8
block41498:
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -40(%rbp)
	movq	-40(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %r11
	movq	%r12, 16(%r11)
	movq	$0, %rbx
	movq	-40(%rbp), %rax
	movq	%rax, -48(%rbp)
	movq	$42, %rax
	jmp mainconclusion

	.align 8
mainstart:
	movq	$1, %rbx
	movq	$2, %r12
	movq	free_ptr(%rip), %r13
	addq	$24, %r13
	movq	fromspace_end(%rip), %r14
	cmpq	%r14, %r13
	jl block41498
	jmp block41499



