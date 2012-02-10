/*
 * Milkymist SoC (Software)
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
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

#include <irq.h>
#include <uart.h>
//#include <hw/fmlbrg.h>
#include <hw/sysctl.h>

#include <system.h>

void flush_cpu_icache(void)
{
	asm volatile(
		"wcsr ICC, r0\n"
		"nop\n"
		"nop\n"
		"nop\n"
		"nop\n"
	);
}

void flush_cpu_dcache(void)
{
	asm volatile(
		"wcsr DCC, r0\n"
		"nop\n"
	);
}

void flush_bridge_cache(void)
{
	// TODO:
}

__attribute__((noreturn)) void reboot(void)
{
	uart_force_sync(1); /* flush UART buffers */
	irq_setmask(0);
	irq_enable(0);
	CSR_SYSTEM_ID = 1; /* Writing to CSR_SYSTEM_ID causes a system reset */
	while(1);
}

static void icap_write(int val, unsigned int w)
{
	// TODO
}

__attribute__((noreturn)) void reconf(void)
{
	uart_force_sync(1); /* flush UART buffers */
	irq_setmask(0);
	irq_enable(0);
	// TODO
	while(1);
}
