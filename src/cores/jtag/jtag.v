// JTAG Interface
// Allows memory to be read and written to through JTAG.
//
// The JTAG interface is currently a single In-system Source and Probe.
//
// HOST - Read Memory:
// Set JBUS to 0.
// Wait for JBUS == 0
// Set JBUS = {1'b1, 1'b0, address, 32'd0}
// Wait for JBUS != 0
// Data = JBUS[31:0]
//
// HOST - Write Memory:
// Set JBUS to 0.
// Wait for JBUS == 0
// Set JBUS = {1'b1, 1'b1, address, data}
// Wait for JBUS != 0


module jtag (
	input sys_clk,
	input sys_rst,

	output reg [31:0] wb_adr_o = 32'd0,
	output reg [31:0] wb_dat_o = 32'd0,
	input [31:0] wb_dat_i,
	input wb_ack_i,
	output [3:0] wb_sel_o,
	output reg wb_stb_o = 1'b0,
	output reg wb_cyc_o = 1'b0,
	output reg wb_we_o = 1'b0
);

	assign wb_sel_o = 4'hf;

	wire [65:0] vw_rx_bus;
	reg rx_request = 1'b0, rx_we = 1'b0;
	reg [31:0] rx_adr = 32'd0, rx_data = 32'd0;

	reg tx_ack = 1'b0;
	reg [31:0] tx_data = 32'd0;

	virtual_wire # (
		.WIDTH (66),
		.PROBE_WIDTH (32),
		.INSTANCE_ID ("JBUS")
	) vw_adr_blk (
		.probe ({tx_ack, tx_data}),
		.source (vw_rx_bus)
	);

	always @ (posedge sys_clk) {rx_request, rx_we, rx_adr, rx_data} <= vw_rx_bus;

	always @ (posedge sys_clk)
	begin
		if (sys_rst)
		begin
			wb_adr_o <= 32'd0;
			wb_dat_o <= 32'd0;
			wb_stb_o <= 1'b0;
			wb_cyc_o <= 1'b0;
			wb_we_o <= 1'b0;
		end
		else if (wb_cyc_o & wb_stb_o & wb_ack_i)
		begin
			tx_ack <= 1'b1;
			tx_data <= wb_dat_i;
			wb_cyc_o <= 1'b0;
			wb_stb_o <= 1'b0;
		end
		else if (wb_cyc_o & wb_stb_o)
		begin
		end
		else if (~rx_request)
		begin
			tx_ack <= 1'b0;
			tx_data <= 32'd0;
		end
		else if (rx_request & ~tx_ack)
		begin
			wb_cyc_o <= 1'b1;
			wb_stb_o <= 1'b1;
			wb_adr_o <= rx_adr;
			wb_dat_o <= rx_data;
			wb_we_o <= rx_we;
		end
	end

endmodule

