/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.2.0
 *
 * `cp /usr/bin/nproc /usr/bin/nproc.ORIG \
 * 	&& gcc -o /usr/bin/nproc nproc.c \
 * 	|| mv /usr/bin/nproc.ORIG /usr/bin/nproc`
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/sysinfo.h>
#include <unistd.h>

int main(void)
{
	const char* env = getenv("NPROC");
	int nproc;

	if(env)
	{
		nproc = atoi(env);
	}
	else
	{
		nproc = 0;
	}
	
	if(nproc < 1)
	{
		nproc = sysconf(_SC_NPROCESSORS_ONLN);
	}
	
	if(nproc < 1)
	{
		nproc = get_nprocs();
	}

	if(nproc < 1)
	{
		nproc = 1;
	}

	printf("%d\n", nproc);
}

