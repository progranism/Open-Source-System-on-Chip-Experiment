/*
 * Milkymist SoC
 * Copyright (C) 2007, 2008, 2009, 2010 Sebastien Bourdeauducq
 * Copyright (C) 2010 Michael Walle
 * Copyright (C) 2012 William Heatley
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

`include "lm32_include.v"

module monitor (
	input sys_clk,
	input sys_rst,

	input write_lock,

	input [31:0] wb_adr_i,
	output [31:0] wb_dat_o,
	input [31:0] wb_dat_i,
	input [3:0] wb_sel_i,
	input wb_stb_i,
	input wb_cyc_i,
	output wb_ack_o,
	input wb_we_i
);

`ifdef CFG_GDBSTUB_ENABLED
	/* 8kb ram */
	localparam ROM_FILE = "software/gdbstub/gdbstub.mif";
	localparam ROM_SIZE = 2048 * 4;
`else
	/* 2kb ram */
	localparam ROM_FILE = "software/monitor/monitor.mif";
	localparam ROM_SIZE = 512 * 4;
`endif

	wb_ebr_ctrl # (
		.SIZE (ROM_SIZE),
		.INIT_FILE (ROM_FILE)
	) ram_blk (
		.CLK_I (sys_clk),
		.RST_I (sys_rst),
		.EBR_ADR_I (wb_adr_i),
		.EBR_DAT_I (wb_dat_i),
		.EBR_WE_I (wb_we_i),
		.EBR_CYC_I (wb_cyc_i),
		.EBR_STB_I (wb_stb_i),
		.EBR_SEL_I (wb_sel_i),
		.EBR_CTI_I (),
		.EBR_BTE_I (),
		.EBR_LOCK_I (),
		.EBR_DAT_O (wb_dat_o),
		.EBR_ACK_O (wb_ack_o),
		.EBR_ERR_O (),
		.EBR_RTY_O ()
	);

endmodule

