/*
 * lm32 JTAG monitor
 * 
 * Copyright (C) 2009 by Michael Walle <michael@walle.cc>
 * Loosly based on Jon Beniston's LatticeMico32 JTAG monitor.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

/* Exception handlers - Must be 32 bytes long. */

.section    .text, "ax", @progbits
.global     _start  

#define MONITOR_VERSION 2

_start:    
_reset_handler:
	xor	r0, r0, r0		/* Clear r0 */
	mvi	ba, 0
	bi	_breakpoint_handler	/* Just call our bp handler */
	nop
	nop
	nop
	nop
	nop

/*	rx_data = 0x60002000
	rx_ack  = 0x60002004
	tx_data = 0x60002008
	tx_ack	= 0x6000200C
*/


_breakpoint_handler:
	xor	r0, r0, r0
	xor	r20, r20, r20
	xor	r21, r21, r21
	xor	r22, r22, r22
	xor	r23, r23, r23

	mvhi	r20, hi(0x60002000)
	ori	r20, r20, lo(0x60002000)
	addi	r21, r20, 4
	addi	r22, r20, 8
	addi	r23, r20, 12

read_byte:
	lw	r1, (r20+0)
	bne	r1, r0, read_byte
	sw	(r21+0), r0
read_byte1:
	lw	r1, (r20+0)
	be	r1, r0, read_byte1
	sw	(r21+0), r1
	andi	r1, r1, 0xFF

	addi	r1, r1, 1

	sw	(r22+0), r0
	andi	r1, r1, 0xFF
	ori	r1, r1, 0x100
send_byte:
	lw	r2, (r23+0)
	bne	r2, r0, send_byte
	sw	(r22+0), r1
send_byte1:
	lw	r2, (r23+0)
	be	r2, r0, send_byte1


/*	mvi	r1, 'T'
	sw	(r22+0), r1*/
	bi	read_byte

