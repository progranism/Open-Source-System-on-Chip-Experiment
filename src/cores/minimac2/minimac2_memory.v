/*
 * Milkymist SoC
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

module minimac2_memory(
	input sys_clk,
	input sys_rst,
	input phy_rx_clk,
	input phy_tx_clk,
	
	input [31:0] wb_adr_i,
	output [31:0] wb_dat_o,
	input [31:0] wb_dat_i,
	input [3:0] wb_sel_i,
	input wb_stb_i,
	input wb_cyc_i,
	output reg wb_ack_o,
	input wb_we_i,
	
	input [7:0] rxb0_dat,
	input [10:0] rxb0_adr,
	input rxb0_we,
	input [7:0] rxb1_dat,
	input [10:0] rxb1_adr,
	input rxb1_we,
	
	output [7:0] txb_dat,
	input [10:0] txb_adr

);

reg wb_old_cyc = 1'b0;
wire wb_en = wb_cyc_i & wb_stb_i;// & ~wb_old_cyc;
wire [1:0] wb_buf = wb_adr_i[12:11];
wire [31:0] wb_dat_i_le = {wb_dat_i[7:0], wb_dat_i[15:8], wb_dat_i[23:16], wb_dat_i[31:24]};
wire [3:0] wb_sel_i_le = {wb_sel_i[0], wb_sel_i[1], wb_sel_i[2], wb_sel_i[3]};

wire [31:0] rxb0_wbdat;
minimac2_altera_memory rxb0 (
	.sys_clk (sys_clk),
	.wb_adr_i (wb_adr_i[10:2]),
	.wb_dat_i (wb_dat_i_le),
	.wb_we_i (wb_en & wb_we_i & (wb_buf == 2'b00)),
	.wb_sel_i (wb_sel_i_le),
	.wb_dat_o (rxb0_wbdat),

	.phy_clk (phy_rx_clk),
	.phy_adr_i (rxb0_adr),
	.phy_dat_i (rxb0_dat),
	.phy_we_i (rxb0_we),
	.phy_dat_o ()
);


wire [31:0] rxb1_wbdat;
minimac2_altera_memory rxb1 (
	.sys_clk (sys_clk),
	.wb_adr_i (wb_adr_i[10:2]),
	.wb_dat_i (wb_dat_i_le),
	.wb_we_i (wb_en & wb_we_i & (wb_buf == 2'b01)),
	.wb_sel_i (wb_sel_i_le),
	.wb_dat_o (rxb1_wbdat),

	.phy_clk (phy_rx_clk),
	.phy_adr_i (rxb1_adr),
	.phy_dat_i (rxb1_dat),
	.phy_we_i (rxb1_we),
	.phy_dat_o ()
);


wire [31:0] txb_wbdat;
minimac2_altera_memory txb (
	.sys_clk (sys_clk),
	.wb_adr_i (wb_adr_i[10:2]),
	.wb_dat_i (wb_dat_i_le),
	.wb_we_i (wb_en & wb_we_i & (wb_buf == 2'b10)),
	.wb_sel_i (wb_sel_i_le),
	.wb_dat_o (txb_wbdat),

	.phy_clk (phy_tx_clk),
	.phy_adr_i (txb_adr),
	.phy_dat_i (8'd0),
	.phy_we_i (1'b0),
	.phy_dat_o (txb_dat)
);

always @(posedge sys_clk) begin
	wb_old_cyc <= wb_cyc_i;

	if(sys_rst)
		wb_ack_o <= 1'b0;
	else begin
		wb_ack_o <= 1'b0;
		if(wb_en & ~wb_ack_o)
			wb_ack_o <= 1'b1;
	end
end

reg [1:0] wb_buf_r;
always @(posedge sys_clk)
	wb_buf_r <= wb_buf;

reg [31:0] wb_dat_o_le;
always @(*) begin
	case(wb_buf_r)
		2'b00: wb_dat_o_le = rxb0_wbdat;
		2'b01: wb_dat_o_le = rxb1_wbdat;
		default: wb_dat_o_le = txb_wbdat;
	endcase
end
assign wb_dat_o = {wb_dat_o_le[7:0], wb_dat_o_le[15:8], wb_dat_o_le[23:16], wb_dat_o_le[31:24]};

endmodule
