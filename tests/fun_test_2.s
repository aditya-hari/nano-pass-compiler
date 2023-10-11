	.align 8
map41820conclusion:
	subq	$0, %r15
	addq	$32, %rsp
	popq	%rbx
	popq	%r13
	popq	%r12
	popq	%r14
	popq	%rbp
	retq

	.align 8
map41820:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	pushq	%r14
	pushq	%r12
	pushq	%r13
	pushq	%rbx
	jmp map41820start

	.align 8
map41820start:
	movq	%rdi, %r12
	movq	%rsi, -40(%rbp)
	movq	-40(%rbp), %r11
	movq	8(%r11), %rbx
	movq	%rbx, %rdi
	callq	*%r12
	movq	%rax, %rbx
	movq	-40(%rbp), %r11
	movq	16(%r11), %r13
	movq	%r13, %rdi
	callq	*%r12
	movq	%rax, %r13
	movq	free_ptr(%rip), %r12
	addq	$24, %r12
	movq	fromspace_end(%rip), %r14
	cmpq	%r14, %r12
	jl block41879
	jmp block41880

	.align 8
block41880:
	movq	%r15, %rdi
	movq	$24, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	%r13, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	jmp map41820conclusion

	.align 8
block41879:
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -56(%rbp)
	movq	-56(%rbp), %r11
	movq	%rbx, 8(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %r11
	movq	%r13, 16(%r11)
	movq	$0, %rbx
	movq	-56(%rbp), %rax
	jmp map41820conclusion

	.align 8
inc41821conclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.align 8
inc41821:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	jmp inc41821start

	.align 8
inc41821start:
	movq	%rdi, %rcx
	movq	%rcx, %rax
	addq	$1, %rax
	jmp inc41821conclusion

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
	leaq	map41820(%rip), %r12
	leaq	inc41821(%rip), %rax
	movq	%rax, -56(%rbp)
	movq	$0, %r14
	movq	$41, %r13
	movq	free_ptr(%rip), %rbx
	movq	%rbx, -40(%rbp)
	addq	$24, -40(%rbp)
	movq	fromspace_end(%rip), %rbx
	cmpq	%rbx, -40(%rbp)
	jl block41881
	jmp block41882

	.align 8
block41882:
	movq	%r15, %rdi
	movq	$24, %rsi
	callq	collect
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -72(%rbp)
	movq	-72(%rbp), %r11
	movq	%r14, 8(%r11)
	movq	$0, %rbx
	movq	-72(%rbp), %r11
	movq	%r13, 16(%r11)
	movq	$0, %rbx
	movq	-72(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	-56(%rbp), %rdi
	movq	-64(%rbp), %rsi
	callq	*%r12
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	16(%r11), %rax
	jmp mainconclusion

	.align 8
block41881:
	movq	free_ptr(%rip), %r11
	addq	$24, free_ptr(%rip)
	movq	$5, 0(%r11)
	movq	%r11, -72(%rbp)
	movq	-72(%rbp), %r11
	movq	%r14, 8(%r11)
	movq	$0, %rbx
	movq	-72(%rbp), %r11
	movq	%r13, 16(%r11)
	movq	$0, %rbx
	movq	-72(%rbp), %rax
	movq	%rax, -64(%rbp)
	movq	-56(%rbp), %rdi
	movq	-64(%rbp), %rsi
	callq	*%r12
	movq	%rax, -48(%rbp)
	movq	-48(%rbp), %r11
	movq	16(%r11), %rax
	jmp mainconclusion



