#include <stdio.h>
#include "my_jtag_atlantic.h"
#include "fcntl.h"

int main (int argc, char *argv[])
{
	JTAGATLANTIC *link;

	printf ("Openning JTAG Atlantic Link...\n");
	link = jtagatlantic_open (0, 0x0, -1, 0);

	if (!link) {
		printf ("Unable to open JTAG Atlantic link.\n");
		return -1;
	}

	printf ("Link established.\n\n");

	if (jtagatlantic_flush(link)) {
		printf("\n\nError on JTAG Link flush\n\nExiting\n");
	        return(-1);
	}

	const char *readbuf = "Guten tag";

	printf ("Writing some test data...\n");

	if (jtagatlantic_write(link, readbuf, 10) == -1) {
		printf("\n\nERROR DURING WRITE\n\n");
		return -1;
	}

	if (jtagatlantic_flush(link)) {
		printf("\n\nError on JTAG Link flush\n\nExiting\n");
	        return(-1);
	}

	printf ("Data written.\n\n");

	char buf[128];

	buf[128] = 0;

	printf ("Reading data...\n");

	int result = jtagatlantic_read (link, buf, 127);

	printf ("Readback: %d\n%s\n--\n", result, buf);

	jtagatlantic_close (link);

	return 0;
}

