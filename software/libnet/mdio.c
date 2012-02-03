/*
 * Derived from Milkymist SoC (Software)
 * Copyright (C) 2012 William Heatley
 * Copyright (C) 2007, 2008, 2009, 2010 Sebastien Bourdeauducq
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

#include <hw/minimac.h>
#include <net/mdio.h>

static void delay(void)
{
	volatile int i;
	for(i=0;i<1000;i++);
}

static void raw_write(unsigned int word, int bitcount)
{
	word <<= 32 - bitcount;
	while(bitcount > 0) {
		if(word & 0x80000000) {
			CSR_MINIMAC_MDIO = MINIMAC_MDIO_DO|MINIMAC_MDIO_OE;
			delay();
			CSR_MINIMAC_MDIO = MINIMAC_MDIO_CLK|MINIMAC_MDIO_DO|MINIMAC_MDIO_OE;
			delay();
			CSR_MINIMAC_MDIO = MINIMAC_MDIO_DO|MINIMAC_MDIO_OE;
		} else {
			CSR_MINIMAC_MDIO = MINIMAC_MDIO_OE;
			delay();
			CSR_MINIMAC_MDIO = MINIMAC_MDIO_CLK|MINIMAC_MDIO_OE;
			delay();
			CSR_MINIMAC_MDIO = MINIMAC_MDIO_OE;
		}
		word <<= 1;
		bitcount--;
	}
}

static unsigned int raw_read(void)
{
	unsigned int word;
	unsigned int i;

	word = 0;
	for(i=0;i<16;i++) {
		delay();
		CSR_MINIMAC_MDIO = MINIMAC_MDIO_CLK;
		delay();
		CSR_MINIMAC_MDIO = 0;

		word <<= 1;
		if(CSR_MINIMAC_MDIO & MINIMAC_MDIO_DI)
			word |= 1;
	}

	return word;
}

static void raw_turnaround(void)
{
	delay();
	CSR_MINIMAC_MDIO = MINIMAC_MDIO_CLK;
	delay();
	CSR_MINIMAC_MDIO = 0;
}

void mdio_write(int phyadr, int reg, int val)
{
	CSR_MINIMAC_MDIO = MINIMAC_MDIO_OE;
	raw_write(0xffffffff, 32); /* < sync */
	raw_write(0x05, 4); /* < start + write */
	raw_write(phyadr, 5);
	raw_write(reg, 5);

	raw_write(0x02, 2); /* < turnaround */
	raw_write(val, 16);

	CSR_MINIMAC_MDIO = 0;
	raw_turnaround();
}

int mdio_read(int phyadr, int reg)
{
	int r;
	
	CSR_MINIMAC_MDIO = MINIMAC_MDIO_OE;
	raw_write(0xffffffff, 32); /* < sync */
	raw_write(0x06, 4); /* < start + read */
	raw_write(phyadr, 5);
	raw_write(reg, 5);

	CSR_MINIMAC_MDIO = 0;
	raw_turnaround();
	r = raw_read();
	raw_turnaround();
	
	return r;
}


// Higher level functions
static void eth_reset_delay(void)
{
	volatile int count = 0;

	// TODO: Use a real timer
	for (; count <= 2000000; ++count);
}

void eth_soft_reset (void)
{
	mdio_write (ETH_PHY_ADR, 0, mdio_read (ETH_PHY_ADR, 0) | (1 << 15));
	while (mdio_read (ETH_PHY_ADR, 0) & (1 << 15));
}

// Disable 1000Mbps negotiation.
// NOTE: A software reset or re-auto negotiation is needed after calling this.
void eth_disable_1000 (void)
{
	int x = mdio_read (ETH_PHY_ADR, 9);
	x &= ~((1 << 9) | (1 << 8));
	mdio_write (ETH_PHY_ADR, 9, x);
}

void eth_reset(void)
{
	CSR_MINIMAC_SETUP = MINIMAC_SETUP_PHYRST;
	eth_reset_delay();
	CSR_MINIMAC_SETUP = 0;
	eth_reset_delay();

	// Hardware currently does not support 1000Mbps
	// TODO: Hardware actually only supports 100Mbps right now...
	eth_disable_1000 ();
	eth_soft_reset ();
}

// Enables loopback on the Ethernet PHY.
// NOTE: Software reset will disable loopback.
void eth_enable_loopback (void)
{
	// Set to 100Mbps
	int x = mdio_read (ETH_PHY_ADR, 20) & ~(7 << 4);
	mdio_write (ETH_PHY_ADR, 20,  x | (5 << 4));
	eth_soft_reset ();

	// Loopback
	mdio_write (ETH_PHY_ADR, 0, mdio_read (ETH_PHY_ADR, 0) | (1 << 14));
}

