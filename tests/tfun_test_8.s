	.align 8
multiply41111conclusion:
	subq	$0, %r15
	addq	$0, %rsp
	popq	%rbp
	retq

	.align 8
multiply41111:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0, %rsp
	jmp multiply41111start

	.align 8
multiply41111start:
	movq	%rdi, %rcx
	movq	%rcx, %rdx
	jmp loop41129

	.align 8
loop41129:
	movq	%rsi, %rcx
	movq	$1, %rax
	cmpq	%rcx, %rax
	jl block41130
	jmp block41131

	.align 8
block41130:
	addq	%rcx, %rdx
	movq	$1, %rcx
	negq	%rcx
	addq	%rcx, %rsi
	jmp loop41129

	.align 8
block41131:
	movq	%rdx, %rax
	jmp multiply41111conclusion

	.align 8
mainconclusion:
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	retq

	.globl main
	.align 8
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	pushq	%rbx
	movq	$16384, %rdi
	movq	$16384, %rsi
	callq	initialize
	movq	rootstack_begin(%rip), %r15
	addq	$0, %r15
	jmp mainstart

	.align 8
mainstart:
	leaq	multiply41111(%rip), %rbx
	movq	$4, %rdi
	movq	$5, %rsi
	movq	%rbx, %rax
	subq	$0, %r15
	addq	$8, %rsp
	popq	%rbx
	popq	%rbp
	jmp *%rax



