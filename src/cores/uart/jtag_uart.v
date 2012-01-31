// Uses alt_jtag_atlantic megafunction to implement a JTAG-UART bridge.

module jtag_uart # (
	parameter INSTANCE_ID = 0
) (
	input clk,
	input rst,
	input [7:0] rx_data,
	input rx_we,
	input rx_rd,
	output [7:0] tx_data,
	output tx_full,
	output tx_empty
);

	wire wfifo_empty, rfifo_full;
	reg fifo_wr = 1'b0;

	wire [7:0] jtag_data, jtag_q;
	wire jtag_can_write, jtag_can_read;
	reg jtag_we = 1'b0, jtag_rd = 1'b1;

	wire rd_wfifo = jtag_can_write & ~wfifo_empty;
	wire wr_rfifo = jtag_can_read & ~rfifo_full;

	// CPU->JTAG FIFO
	scfifo # (
		.lpm_hunt ("RAM_BLOCK_TYPE=AUTO"),
		.lpm_numwords (64),
		.lpm_showahead ("OFF"),
		.lpm_type ("scfifo"),
		.lpm_width (8),
		.lpm_widthu (6),
		.overflow_checking ("OFF"),
		.underflow_checking ("OFF"),
		.use_eab ("ON")
	) wfifo (
		.clock (clk),
		.data (rx_data),
		.empty (wfifo_empty),
		.full (tx_full),
		.q (jtag_data),
		.rdreq (rd_wfifo),
		.usedw (),
		.wrreq (rx_we & ~tx_full)
	);

	// JTAG->CPU FIFO
	scfifo # (
		.lpm_hunt ("RAM_BLOCK_TYPE=AUTO"),
		.lpm_numwords (64),
		.lpm_showahead ("OFF"),
		.lpm_type ("scfifo"),
		.lpm_width (8),
		.lpm_widthu (6),
		.overflow_checking ("OFF"),
		.underflow_checking ("OFF"),
		.use_eab ("ON")
	) rfifo (
		.clock (clk),
		.data (jtag_q),
		.empty (tx_empty),
		.full (rfifo_full),
		.q (tx_data),
		.rdreq (rx_rd & ~tx_empty),
		.usedw (),
		.wrreq (wr_rfifo)
	);

	// JTAG Atlantic
	alt_jtag_atlantic # (
		.INSTANCE_ID (INSTANCE_ID),
		.LOG2_RXFIFO_DEPTH (6),
		.LOG2_TXFIFO_DEPTH (6)
	) jtag_uart_blk (
		.clk (clk),
		.r_dat (jtag_data),
		.r_ena (jtag_can_write),
		.r_val (jtag_we),
		.rst_n (~rst),
		.t_dat (jtag_q),
		.t_dav (jtag_rd),
		.t_ena (jtag_can_read),
		.t_pause ()	// UART Pause/Break
	);


	always @ (posedge clk or posedge rst)
	begin
		if (rst)
		begin
			jtag_we <= 1'b0;
			jtag_rd <= 1'b1;
		end
		else
		begin
			jtag_we <= jtag_can_write & ~wfifo_empty;
			jtag_rd <= ~rfifo_full;
		end
	end

endmodule

