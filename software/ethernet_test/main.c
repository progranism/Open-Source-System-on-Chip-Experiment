/*
 * Derived from Milkymist SoC (Software)
 * Copyright (C) 2012 William Heatley
 * Copyright (C) 2007, 2008, 2009, 2010, 2011 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */



#include <hw/gpio.h>
#include <hw/uart.h>
#include <hw/minimac.h>
#include <net/mdio.h>


static void print_mac(void)
{
	const unsigned char macadr[] = {0xF6, 0x13, 0x06, 0xE8, 0x53, 0xDF};

	printf("I: MAC address: %02x:%02x:%02x:%02x:%02x:%02x\n", macadr[0], macadr[1], macadr[2], macadr[3], macadr[4], macadr[5]);
}

static void ethreset_delay(void)
{
	volatile int count = 0;

	// TODO: Use a real timer
	for (; count <= 2000000; ++count);
}

static void ethreset(void)
{
	CSR_MINIMAC_SETUP = MINIMAC_SETUP_PHYRST;
	ethreset_delay();
	CSR_MINIMAC_SETUP = 0;
	ethreset_delay();
}

int main(int i, char **c)
{
	int count = 0;

	ethreset_delay();
	ethreset();
	print_mac();
	ethreset();
	ethreset_delay();

	// Test MDIO
	count = 18;
	int x = mdio_read (count, 2);
	printf ("I: PHY %d ID0: %04X\n", count, x);
	count = 18;
	x = mdio_read (count, 3);
	printf ("I: PHY %d ID1: %04X\n", count, x);

	while (1)
	{
		if (count == 1000000) {
			CSR_GPIO = (CSR_GPIO&1) ? 0xF0F0F0F0 : 0x0F0F0F0F;
			count = 0;
		}

		count++;

		if (CSR_UART_RX != 0 && CSR_UART_TX == 0) {
			CSR_UART_TX = CSR_UART_RX & 0xFF;
			CSR_UART_RX = 0;
		}
	}

	return 0;
}

void isr (void)
{
}

