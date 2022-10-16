// afib.S

.global main

.data
	error_message: .string "Usage: ./fib N, where N >= 0 \n"
	answer_message: .string "fib(%d) = %d\n"

.text

	/* long afib(long xx)
	Variables:
	- xx is %rdi
	- xx-1 is %r12
	- afib(xx-1) is %r13*/
afib:
	push %r12
	push %r13
	enter $0, $0

	//  if(xx<2)
	cmp $2, %rdi
	jl afib_then
	jmp afib_else

	
	//{	return xx;	}
afib_then:
	mov %rdi, %rax
	jmp afib_done
	
	/*else
	{	return afib(xx-1) + afib(xx-2); } */
afib_else:
	dec %rdi //sub 1
	mov %rdi, %r12 //save to 12
	call afib //recursion 1, moves output to rax
	mov %rax, %r13 //save in r13
	mov %r12, %rdi 
	dec %rdi //sub 1 for total sub 2
	call afib //recursion 2
	add %r13, %rax //add afib(xx-1) to afib(xx-2)
	
afib_done:
	leave
	pop %r13
	pop %r12
	ret
	


	/*long main(int argc, char* argv[])
	Variables:
	- argc is %rdi
	- argv[] is %rsi 
	- atol argv[1] is in r14 
	*/
main:
	push %r14
	enter $8, $0

	//if(argc == 1)
	cmp $1, %rdi 
	jg else1 //if more than one, send it down

	//	printf(Usage: ./fib N, where N >= 0 \n");
	mov $error_message, %rdi
	mov $0, %al
	call printf
	mov $1, %rax
	jmp done
	
	//else if(atol(argv[1]) < 0)
else1:
	//	  printf(Usage: ./fib N, where N >= 0 \n");
	mov 8(%rsi), %rdi //moves second argument to the first spot
	call atol //puts output into rax
	mov %rax, %r14 // copies long version of input to r14
	cmp $0, %rax
	jge else2 // if greater than 0 send to else2:
	
	mov $error_message, %rdi //print error message if below 0
	mov $0, %al // don't know why i need this
	call printf //print error_message
	mov $1, %rax
	jmp done
	
	//else
else2:
	//	long xy = atol(argv[1]);  !!!already done and in r14 !!!
	
	//	long answer = afib(xy);
	mov %r14, %rdi // should copy xy into the input spot and save it in r14
	call afib //puts answer in rax

	//	printf("fib(%d) = %d\n", xy, answer);
	mov %rax, %rdx // moves answer to rdx, argument 3
	mov $answer_message, %rdi // argument 1
	mov %r14, %rsi //moves xy to rsi, argument 2
	mov $0, %al //still not sure why
	call printf

done:
	leave
	pop %r14
	ret
