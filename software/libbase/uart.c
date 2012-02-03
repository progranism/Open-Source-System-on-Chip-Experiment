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

#include <uart.h>
//#include <irq.h>
#include <hw/uart.h>
//#include <hw/interrupts.h>


void uart_isr(void)
{
}

/* Do not use in interrupt handlers! */
char uart_read(void)
{
	char c;

	while (!CSR_UART_RX);	
	c = CSR_UART_RX & 0xFF;
	CSR_UART_RX = 0;
	return c;
}

int uart_read_nonblock(void)
{
	return CSR_UART_RX != 0;
}

void uart_write(char c)
{
	while (CSR_UART_TX);
	CSR_UART_TX = c;
}

void uart_init(void)
{
}

void uart_force_sync(int f)
{
}

