	.align 8
even41948conclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq

	.align 8
even41948:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	pushq	%rbx
	jmp even41948start

	.align 8
block41976:
	movq	$1, %rax
	jmp even41948conclusion

	.align 8
even41948start:
	movq	%rdi, %rcx
	cmpq	$0, %rcx
	je block41976
	jmp block41977

	.align 8
block41977:
	leaq	odd41949(%rip), %rbx
	movq	$1, %rdx
	negq	%rdx
	addq	%rdx, %rcx
	movq	%rcx, %rdi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax

	.align 8
odd41949conclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq

	.align 8
odd41949:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	pushq	%rbx
	jmp odd41949start

	.align 8
odd41949start:
	movq	%rdi, %rdx
	cmpq	$0, %rdx
	je block41978
	jmp block41979

	.align 8
block41978:
	movq	$0, %rax
	jmp odd41949conclusion

	.align 8
block41979:
	leaq	even41948(%rip), %rbx
	movq	$1, %rcx
	negq	%rcx
	addq	%rcx, %rdx
	movq	%rdx, %rdi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax

	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbx
	popq	%r12
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	pushq	%r12
	pushq	%rbx
	movq	$16384, %rdi
	movq	$16384, %rsi
	callq	initialize
	movq	rootstack_begin(%rip), %r15
	addq	$0, %r15
	jmp mainstart

	.align 8
block41981:
	movq	$1, %rax
	jmp mainconclusion

	.align 8
mainstart:
	leaq	even41948(%rip), %r12
	callq	read_int
	movq	%rax, %rbx
	movq	%rbx, %rdi
	callq	*%r12
	movq	%rax, %rbx
	cmpq	$1, %rbx
	je block41980
	jmp block41981

	.align 8
block41980:
	movq	$2, %rax
	jmp mainconclusion



