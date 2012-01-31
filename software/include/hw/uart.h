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
 * Access to the UART module.
 *
 * To receive data:
 *
 * while (!CSR_UART_RX);	// Wait for data
 * byte = CSR_UART_RX & 0xFF;	// Grab data
 * CSR_UART_RX = 0;		// Clear buffer so more data can come in
 *
 *
 * To send data:
 *
 * while (CSR_UART_TX);		// Wait for room to send a byte
 * CSR_UART_TX = byte;		// Send byte
 */

#ifndef __HW_UART_H
#define __HW_UART_H

#include <hw/common.h>

#define CSR_UART_RX	MMPTR(0x60002000)
#define CSR_UART_TX	MMPTR(0x60002004)

#endif

