// Handles UART communication.
// Currently UART is only handled over JTAG using the Altera JTAG Atlantic
// megafunction.
//
// Should be compatiable with Milkymist's UART.
//
//


module uart #(
	parameter csr_addr = 4'h0,
	parameter JTAG_INSTANCE_ID = 0
) (
	input sys_clk,
	input sys_rst,

	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output reg [31:0] csr_do,

	output tx_irq
);

	reg [7:0] rx_reg = 8'd0, tx_reg = 8'd0;
	reg [15:0] divisor;
	reg thru_en, break_en, tx_irq_en, rx_irq_en, rx_event, tx_event, thre;

	wire csr_selected = csr_a[13:10] == csr_addr;
	wire [7:0] jtag_q;
	reg jtag_rd = 1'b0;
	wire jtag_full, jtag_empty;

	wire jtag_we = ~jtag_full & ~thre;
	wire read_jtag = ~jtag_rd & ~jtag_empty & ~rx_event;


	jtag_uart # (
		.INSTANCE_ID (JTAG_INSTANCE_ID)
	) jtag_uart_blk (
		.clk (sys_clk),
		.rst (sys_rst),
		.rx_data (tx_reg),
		.rx_we (jtag_we),
		.rx_rd (read_jtag),
		.tx_data (jtag_q),
		.tx_full (jtag_full),
		.tx_empty (jtag_empty)
	);


	assign tx_irq = (tx_event & tx_irq_en) | (rx_event & rx_irq_en);


	always @ (posedge sys_clk)
	begin
		if (sys_rst)
		begin
			divisor <= 16'd27;
			csr_do <= 32'd0;
			thru_en <= 1'b0;
			break_en <= 1'b0;
			rx_irq_en <= 1'b0;
			tx_irq_en <= 1'b0;
			tx_event <= 1'b0;
			rx_event <= 1'b0;
			thre <= 1'b1;

			rx_reg <= 8'd0;
			tx_reg <= 8'd0;
			jtag_rd <= 1'b0;
		end
		else
		begin
			csr_do <= 32'd0;

			if (csr_selected & csr_we & (csr_a[2:0] == 3'b000))
			begin
				thre <= 1'b0;
				tx_reg <= csr_di[7:0];
			end

			if (jtag_we)
			begin
				tx_event <= 1'b1;
				thre <= 1'b1;
			end

			// Read from JTAG-UART to our RX register
			if (jtag_rd)
			begin
				rx_reg <= jtag_q;
				rx_event <= 1'b1;
			end

			jtag_rd <= read_jtag;

			

			

			// CSR
			if (csr_selected)
			begin
				case (csr_a[2:0])
					3'b000: csr_do <= rx_reg;
					3'b001: csr_do <= divisor;
					3'b010: csr_do <= {tx_event, rx_event, thre};
					3'b011: csr_do <= {thru_en, tx_irq_en, rx_irq_en};
					3'b100: csr_do <= {break_en};
				endcase

				if (csr_we)
				begin
					case (csr_a[2:0])
						3'b000:; /* handled by transceiver */
						3'b001: divisor <= csr_di[15:0];
						3'b010: begin
							if (csr_di[1])
								rx_event <= 1'b0;
							if (csr_di[2])
								tx_event <= 1'b0;
						end
						3'b011: {thru_en, tx_irq_en, rx_irq_en} <= csr_di[2:0];
						3'b100: break_en <= csr_di[0];
					endcase
				end
			end
		end
	end

endmodule

