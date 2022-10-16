#include<stdio.h>
#include<stdlib.h>

long cfib(long xx)
{
	if(xx < 2)
	{
		return xx;
	}
	else
	{
		return cfib(xx - 1) + cfib(xx - 2);
	}
}

long main(int argc, char* argv[])
{	
	if(argc == 1)
	{
		printf("Usage: ./fib N, where N >= 0 \n");
	}
	else if(atol(argv[1]) < 0)
	{
		printf("Usage:./fib N, where N >= 0 \n");
	}
	else
	{
		long xy = atol(argv[1]);
		long answer = cfib(xy);
		printf("fib(%d) = %d\n", xy, answer);
	}
}
