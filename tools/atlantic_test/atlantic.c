/*
 * Copyright (C) 2012 William Heatley
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/*
 * Just a test of the JTAG Atlantic module, which provides a JTAG-UART bridge.
 */

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

	char buf[512];

	buf[511] = 0;

	printf ("Reading data...\n");

	int result = jtagatlantic_read (link, buf, 511);

	if (result >= 0)
	buf[result] = 0;

	printf ("Readback: %d\n%s\n--\n", result, buf);

	jtagatlantic_close (link);

	return 0;
}

