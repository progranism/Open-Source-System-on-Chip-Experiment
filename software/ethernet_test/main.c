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
#include <net/microudp.h>
#include <stdio.h>

#define ETH_PHY_ADR 18


const unsigned char macadr[] = {0x00, 0x13, 0x06, 0xE8, 0x53, 0xDF};


static void print_mac(void)
{
	printf("I: MAC address: %02x:%02x:%02x:%02x:%02x:%02x\n", macadr[0], macadr[1], macadr[2], macadr[3], macadr[4], macadr[5]);
}

void eth_print_status(void)
{
	int status = mdio_read (ETH_PHY_ADR, 17);
	if (status & (1 << 10))
		printf ("ETH PHY Status: LINK_UP ");
	else {
		printf ("ETH PHY Status: LINK_DOWN :(\n");
		return;
	}

	switch (status >> 14)
	{
	case 3:
		printf ("SPEED-RESERVED ");
		break;
	case 2:
		printf ("SPEED-1000MB ");
		break;
	case 1:
		printf ("SPEED-100MB ");
		break;
	case 0:
		printf ("SPEED-10MB ");
		break;
	}

	if (status & (1 << 13))
		printf ("FULL-DUPLEX ");
	else
		printf ("HALF-DUPLEX ");

	if (status & (1 << 11))
		printf("SPD_DPLX_RSLVD ");
	else
		printf("SPD_DPLX_NOT_RSLVD ");

	if (status & (1 << 6))
		printf("MDIX ");
	else
		printf("MDI ");

	printf ("\n");
}

int main(int i, char **c)
{
	volatile int count = 0;

	// Boot up delay ... not sure if I need this for the Ethernet PHY?
	for (count = 0; count <= 2000000; ++count);

	eth_reset();
	print_mac();

	// Test MDIO
	printf ("I: PHY ID0: %04X\n", mdio_read (ETH_PHY_ADR, 2));
	printf ("I: PHY ID1: %04X\n", mdio_read (ETH_PHY_ADR, 3));

	printf ("Waiting for ethernet link to come up...\n");
	while (1) {
		if (mdio_read (ETH_PHY_ADR, 17) & (1 << 10))
			break;
	}

	eth_print_status ();


	microudp_start (macadr, IPTOINT(0, 0, 0, 0));

	/*printf ("Performing an ARP resolve...\n");
	microudp_arp_resolve (IPTOINT(192, 168, 10, 101));
	printf ("Done performing ARP resolve!\n");*/

	microudp_arp_resolve (0xFFFFFFFF);

	dhcp_boot (macadr);


   	// Some silly test loop
	while (1)
	{
		if (count >= 1000000) {
			CSR_GPIO = (CSR_GPIO&1) ? 0xF0F0F0F0 : 0x0F0F0F0F;
			count = 0;

			// Ethernet test packet
			printf ("Sending a test UDP packet.\n");
			char *packet_data = microudp_get_tx_buffer();
			sprintf (packet_data, "Guten Tag");
			microudp_send (7642, 69, 10);
			printf ("Done sending the test UDP packet.\n");
		}

		count++;

		// Pipe incoming data into the void.
		if (CSR_UART_RX) CSR_UART_RX = 0;

		/*if (CSR_UART_RX != 0 && CSR_UART_TX == 0) {
			CSR_UART_TX = CSR_UART_RX & 0xFF;
			CSR_UART_RX = 0;
		}*/

		microudp_service ();
	}

	return 0;
}

void isr (void)
{
}

