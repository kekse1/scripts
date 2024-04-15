/*
 * Copyright (c) Sebastian Kucharczyk <kuchen@kekse.biz>
 * https://kekse.biz/ https://github.com/kekse1/scripts/
 * v0.2.2
 *
 * `cp /usr/bin/nproc /usr/bin/nproc.ORIG \
 * 	&& gcc -o /usr/bin/nproc nproc.c \
 * 	|| mv /usr/bin/nproc.ORIG /usr/bin/nproc`
 */

#include <string.h>
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
		const unsigned short len = (unsigned short)strnlen(env, 16);

		if(len > 0 && len < 16)
		{
			nproc = atoi(env);
		}
		else
		{
			nproc = 0;
		}
	}
	else
	{
		nproc = 0;
	}

	if(nproc < 1)
	{
		const int a = sysconf(_SC_NPROCESSORS_ONLN);
		const int b = get_nprocs();
		nproc = (a > b ? a : b);

		if(nproc < 1)
		{
			nproc = 1;
		}
	}

	printf("%d\n", nproc);
}

