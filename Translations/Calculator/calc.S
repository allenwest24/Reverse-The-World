.global main

.data
	mult_text: .string "*"
	sum_text: .string "+"
	sub_text: .string "-"
	div_text: .string "/"
	error_msg: .string "Usage: \n	./acalc N op N \n"
	solution_msg: .string "%d %s %d = %d\n"

.text
	/* long acalc(long first, long second, char *op)
	Variables:
	-first in rdi
	-second in rsi
	-op in rdx
	-first to r12
	-second to r13*/

acalc:
	push %r12
	push %rbx
	push %r13
	enter $8, $0

	mov %rdi, %r12 // first in r12
	mov %rsi, %r13 // second in r13
	mov %rdx, %rbx // op in rdi

	//long solution; // will just be in rax
	
	/*switch(op[0])
		case '+':
			solution = first + second;
			break;
		case '*':
			solution = first * second;
			break;
		case '-':
			solution = first - second;
			break;
		case '/':
			solution = frist - second;
			break;
		return solution;*/

	//for subtraction
	mov $sub_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je subtract

	// for multiplication
	mov $mult_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je multiply

	// for addition
	mov $sum_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je sum

	// for division
	mov $div_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je divide

	// nothing should reach this far :)

sum:
	add %r12, %r13
	mov %r13, %rax
	jmp acalc_done

multiply:
	mov %r12, %rax
	imul %r13
	jmp acalc_done

subtract:
	sub %r13, %r12
	mov %r12, %rax
	jmp acalc_done

divide:
	cmp %r12, %r13
	jg bad_divide
	mov %r12, %rax
	cqo
	idiv %r13	
	jmp acalc_done

bad_divide:
	mov $0, %rax
	jmp acalc_done

acalc_done:
	leave
	pop %r13
	pop %rbx
	pop %r12
	ret

	/*long main( int argc, char* argv[])
	Variables:
	-argc in rdi
	-argv[] in rsi
	-argv[1] to r14 then rdi
	-argv[3] to r15 then rsi
	-argv[2] to rbx */	
main:
	push %r14
	push %rbx
	push %r15
	enter $8, $0

	//if argc == 4 &&
	cmp $4, %rdi
	jne error

	//avoids segmentation error because we checked
	mov 16(%rsi), %rbx
	mov 24(%rsi), %r15
	mov 8(%rsi), %rdi // number 1
	call atol
	mov %rax, %r14 // saved as long
	mov %r15, %rdi
	call atol
	mov %rax, %r15 // saved as long

	
	/* if(argc == 4 && (argv[2][0] == '/' || argv[2][0] == '+' || argv[2][0] == '-' || argv[2][0] == '*'))*/

	//for subtraction
	mov $sub_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je good

	// for multiplication
	mov $mult_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je good

	// for addition
	mov $sum_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je good

	// for division
	mov $div_text, %rdi
	mov %rbx, %rsi
	mov $1, %rdx
	call strncmp
	cmp $0, %rax
	je good

	// if its something else
	jmp error

	/*	long arg1 = atol(argv[1]); DONE ABOVE, SAVED IN r14
		long arg3 = atol(argv[3]); DONE ABOVE, SAVED IN r15
		char* operation = rgv[2];  DONE ABOVE, SAVED IN rbx */


	//	printf("%d %s %d = %d\n", arg1, arg[2], arg3, ccalc(arg1, arg3, operation));
	
	/*else
		printf("usage: \n	./acalc N op N \n");
	return 0;*/

error:
	mov $error_msg, %rdi
	mov $0, %al
	call printf
	mov $1, %rax
	jmp done
	
good:
	mov %r14, %rdi
	mov %rbx, %rdx
	mov %r15, %rsi
	call acalc

	mov $solution_msg, %rdi
	mov %r14, %rsi
	mov %rbx, %rdx
	mov %r15, %rcx
	mov %rax, %r8
	mov $0, %al
	call printf
	jmp done

done:	
	leave
	pop %r15
	pop %rbx
	pop %r14
	ret
