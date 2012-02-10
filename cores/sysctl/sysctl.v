/*
 * Milkymist SoC
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


module sysctl # (
	parameter csr_addr = 4'h0,
	parameter noutputs = 8
) (
	input sys_clk,
	input sys_rst,

	/* Interrupts */
	output reg timer0_irq,
	output reg timer1_irq,

	/* CSR bus interface */
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output reg [31:0] csr_do,

	/* GPIO */
	output reg [noutputs-1:0] gpio_outputs
);

	/*
	* Dual timer
	*/

	reg en0, en1;
	reg ar0, ar1;
	reg [31:0] counter0, counter1;
	reg [31:0] compare0, compare1;

	wire match0 = (counter0 == compare0);
	wire match1 = (counter1 == compare1);

	/*
	 * Debug scrachpad register
	 */
	reg [7:0] debug_scratchpad;

	/*
	* Logic and CSR interface
	*/

	wire csr_selected = csr_a[13:10] == csr_addr;

	always @(posedge sys_clk)
	begin
		if(sys_rst)
		begin
			csr_do <= 32'd0;

			timer0_irq <= 1'b0;
			timer1_irq <= 1'b0;

			gpio_outputs <= {noutputs{1'b0}};

			en0 <= 1'b0;
			en1 <= 1'b0;
			ar0 <= 1'b0;
			ar1 <= 1'b0;
			counter0 <= 32'd0;
			counter1 <= 32'd0;
			compare0 <= 32'hFFFFFFFF;
			compare1 <= 32'hFFFFFFFF;

			debug_scratchpad <= 8'd0;
		end
		else
		begin
			timer0_irq <= 1'b0;
			timer1_irq <= 1'b0;

			/* Handle timer 0 */
			if( en0 & ~match0) counter0 <= counter0 + 32'd1;
			if( en0 &  match0) timer0_irq <= 1'b1;
			if( ar0 &  match0) counter0 <= 32'd1;
			if(~ar0 &  match0) en0 <= 1'b0;

			/* Handle timer 1 */
			if( en1 & ~match1) counter1 <= counter1 + 32'd1;
			if( en1 &  match1) timer1_irq <= 1'b1;
			if( ar1 &  match1) counter1 <= 32'd1;
			if(~ar1 &  match1) en1 <= 1'b0;

			csr_do <= 32'd0;
			if(csr_selected)
			begin
				/* CSR Writes */
				if(csr_we)
				begin
					case(csr_a[4:0])
						/* GPIO registers */
						// 00000 is GPIO IN and is read-only
						5'b00001: gpio_outputs <= csr_di[noutputs-1:0];

						/* Timer 0 registers */
						5'b00100: begin
							en0 <= csr_di[0];
							ar0 <= csr_di[1];
						end
						5'b00101: compare0 <= csr_di;
						5'b00110: counter0 <= csr_di;

						/* Timer 1 registers */
						5'b01000: begin
							en1 <= csr_di[0];
							ar1 <= csr_di[1];
						end
						5'b01001: compare1 <= csr_di;
						5'b01010: counter1 <= csr_di;

						/* Debug monitor (gdbstub) */
						5'b10100: debug_scratchpad <= csr_di[7:0];
					endcase
				end

				/* CSR Reads */
				case(csr_a[4:0])
					/* GPIO registers */
					5'b00001: csr_do <= gpio_outputs;

					/* Timer 0 registers */
					5'b00100: csr_do <= {ar0, en0};
					5'b00101: csr_do <= compare0;
					5'b00110: csr_do <= counter0;

					/* Timer 1 registers */
					5'b01000: csr_do <= {ar1, en1};
					5'b01001: csr_do <= compare1;
					5'b01010: csr_do <= counter1;

					/* Debug monitor (gdbstub) */
					5'b10100: csr_do <= debug_scratchpad;

					/* Read only SoC properties */
					5'b11101: csr_do <= 32'd50000000;
				endcase
			end
		end
	end

endmodule

