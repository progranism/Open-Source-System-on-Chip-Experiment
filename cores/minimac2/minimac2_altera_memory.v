//
// Used by Minimac2 to instantiate memory buffers which are accessed by
// wishbone and the PHY.
//
// 2048KB
// 512x32-bit words
//
module minimac2_altera_memory (
	input sys_clk,
	input [8:0] wb_adr_i,
	input [31:0] wb_dat_i,
	input wb_we_i,
	input [3:0] wb_sel_i,
	output [31:0] wb_dat_o,

	input phy_clk,
	input [10:0] phy_adr_i,
	input [7:0] phy_dat_i,
	input phy_we_i,
	output [7:0] phy_dat_o
);

	wire [1:0] phy_adr_byte = phy_adr_i[1:0];
	wire [3:0] phy_sel = {phy_adr_byte == 2'b11, phy_adr_byte == 2'b10, phy_adr_byte == 2'b01, phy_adr_byte == 2'b00};

	wire [31:0] phy_big_dat_o;
	reg [3:0] phy_sel_r = 4'd0;
	assign phy_dat_o = phy_sel_r[3] ? phy_big_dat_o[31:24] : phy_sel_r[2] ? phy_big_dat_o[23:16] : phy_sel_r[1] ? phy_big_dat_o[15:8] : phy_big_dat_o[7:0];

	always @ (posedge phy_clk) phy_sel_r <= phy_sel;

altsyncram # (
	.address_reg_b ("CLOCK1"),
	.byteena_reg_b ("CLOCK1"),
	.byte_size (8),
	.clock_enable_input_a ("BYPASS"),
	.clock_enable_input_b ("BYPASS"),
	.clock_enable_output_a ("BYPASS"),
	.clock_enable_output_b ("BYPASS"),
	.indata_reg_b ("CLOCK1"),
	.intended_device_family ("Cyclone III"),
	.lpm_type ("altsyncram"),
	.numwords_a (512),
	.numwords_b (512),
	.operation_mode ("BIDIR_DUAL_PORT"),
	.outdata_aclr_a ("NONE"),
	.outdata_aclr_b ("NONE"),
	.outdata_reg_a ("UNREGISTERED"/*"CLOCK0"*/),
	.outdata_reg_b ("UNREGISTERED"/*"CLOCK1"*/),
	.power_up_uninitialized ("FALSE"),
	.read_during_write_mode_port_a ("NEW_DATA_NO_NBE_READ"),
	.read_during_write_mode_port_b ("NEW_DATA_NO_NBE_READ"),
	.widthad_a (9),
	.widthad_b (9),
	.width_a (32),
	.width_b (32),
	.width_byteena_a (4),
	.width_byteena_b (4),
	.wrcontrol_wraddress_reg_b ("CLOCK1")
) mem_blk (
	.clock0 (sys_clk),
	.address_a (wb_adr_i),
	.wren_a (wb_we_i),
	.byteena_a (wb_sel_i),
	.data_a (wb_dat_i),
	.q_a (wb_dat_o),

	.clock1 (phy_clk),
	.address_b (phy_adr_i[10:2]),
	.wren_b (phy_we_i),
	.byteena_b (phy_sel),
	.data_b ({phy_dat_i, phy_dat_i, phy_dat_i, phy_dat_i}),
	.q_b (phy_big_dat_o),

	.aclr0 (1'b0),
	.aclr1 (1'b0),
	.addressstall_a (1'b0),
	.addressstall_b (1'b0),
	.clocken0 (1'b1),
	.clocken1 (1'b1),
	.clocken2 (1'b1),
	.clocken3 (1'b1),
	.eccstatus (),
	.rden_a (1'b1),
	.rden_b (1'b1)
);

endmodule

