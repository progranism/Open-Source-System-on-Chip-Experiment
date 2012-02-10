/*
 * Derived from Milkymist VJ SoC
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

module gpio #(
	parameter csr_addr = 4'h0
) (
	input sys_clk,
	input sys_rst,

	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output reg [31:0] csr_do,

	output reg [31:0] gpio_outputs
);

	wire csr_selected = csr_a[13:10] == csr_addr;

	always @ (posedge sys_clk)
	begin
		if (sys_rst)
		begin
			csr_do <= 32'd0;

			gpio_outputs <= 32'd0;
		end
		else
		begin
			csr_do <= 32'd0;

			if (csr_selected)
			begin
				if (csr_we)
				begin
					case (csr_a[3:0])
						4'b0001: gpio_outputs <= csr_di[31:0];
					endcase
				end

				case(csr_a[3:0])
					4'b0001: csr_do <= gpio_outputs;
				endcase
			end
		end
	end

endmodule
	
