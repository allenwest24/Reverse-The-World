#include<stdio.h>
#include<stdlib.h>
#include<math.h>

long ccalc(long first, long second, char *op)
{
	long solution;

	switch(op[0])
	{
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
			solution = first / second;
			break;
	}
	return solution;
}

long main(int argc, char* argv[])
{
	if(argc == 4 && (argv[2][0] == '/' || argv[2][0] == '+' || argv[2][0] == '-' || argv[2][0] == '*'))
	{
		long arg1 = atol(argv[1]);
		long arg3 = atol(argv[3]);
		char* operation = argv[2];
		printf("%d %s %d = %d\n", arg1, argv[2], arg3, ccalc(arg1, arg3, operation));
	}
	else
	{
		printf("Usage: \n	./ccalc N op N \n");
		return 1;
	}
	return 0;
}
