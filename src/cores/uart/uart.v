// Handles UART communication.
// Currently UART is only handled over JTAG using the Altera JTAG Atlantic
// megafunction.
//
// RX (External->CPU) is handled by register 0x0.
// TX (CPU->External) is handled by register 0x1.
//
// If data is available, it can be read from RX.
// Writing anything to RX will retreieve the next available byte.
//
// TX will equal 0 if data can be sent. Only write to TX if TX equals 0.
//
//
// CPU Usage - Read Byte
// while (!CSR_UART_RX);
// byte = CSR_UART_RX & 0xFF;
// CSR_UART_RX = 0;
//
// CPU Usage - Write Byte
// while (CSR_UART_TX);
// CSR_UART_TX = byte;
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
	output reg [31:0] csr_do
);

	wire csr_selected = csr_a[13:10] == csr_addr;
	reg [31:0] rx_reg = 32'd0, tx_reg = 32'd0;
	wire [7:0] jtag_q;
	reg jtag_we = 1'b0, jtag_rd = 1'b0;
	wire jtag_full, jtag_empty;

	wire read_jtag = ~jtag_rd && ~jtag_empty && (rx_reg == 32'd0);


	jtag_uart # (
		.INSTANCE_ID (JTAG_INSTANCE_ID)
	) jtag_uart_blk (
		.clk (sys_clk),
		.rst (sys_rst),
		.rx_data (tx_reg[7:0]),
		.rx_we (jtag_we),
		.rx_rd (read_jtag),
		.tx_data (jtag_q),
		.tx_full (jtag_full),
		.tx_empty (jtag_empty)
	);


	always @ (posedge sys_clk)
	begin
		if (sys_rst)
		begin
			csr_do <= 32'd0;

			rx_reg <= 32'd0;
			tx_reg <= 32'd0;
			jtag_we <= 1'b0;
			jtag_rd <= 1'b0;
		end
		else
		begin
			csr_do <= 32'd0;

			// Read from JTAG-UART to our RX register
			if (jtag_rd)
				rx_reg <= {24'd1, jtag_q};

			jtag_rd <= read_jtag;

			// Write to JTAG-UART from our TX register
			if (jtag_we)
			begin
				jtag_we <= 1'b0;
				tx_reg <= 32'd0;
			end
			else if (tx_reg != 32'd0 && ~jtag_full)
				jtag_we <= 1'b1;

			

			// CSR
			if (csr_selected)
			begin
				if (csr_we)
				begin
					if (csr_a[3:0] == 4'b0000 && ~jtag_rd)
						rx_reg <= csr_di[31:0];

					if (csr_a[3:0] == 4'b0001 && ~jtag_we)
						tx_reg <= {24'd1, csr_di[7:0]};
				end

				case(csr_a[3:0])
					4'b0000: csr_do <= rx_reg;
					4'b0001: csr_do <= tx_reg;
				endcase
			end
		end
	end

endmodule

