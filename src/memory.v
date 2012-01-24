module memory # (
	parameter ADDRESS_WIDTH = 1,
	parameter DATA_WIDTH = 1
       ) (
	input clka,
	input rsta,
	input enable_read,
	input [ADDRESS_WIDTH-1:0] read_address,
	input enable_write,
	input [ADDRESS_WIDTH-1:0] write_address,
	input [DATA_WIDTH-1:0] write_data,
	output [DATA_WIDTH-1:0] read_data
);

	altsyncram altsyncram_component (
		.address_a (write_address),
		.clock0 (clka),
		.data_a (write_data),
		.rden_b (enable_read),
		.wren_a (enable_write),
		.address_b (read_address),
		.q_b (read_data),
		.aclr0 (1'b0),
		.aclr1 (1'b0),
		.addressstall_a (1'b0),
		.addressstall_b (1'b0),
		.byteena_a (1'b1),
		.byteena_b (1'b1),
		.clock1 (1'b1),
		.clocken0 (1'b1),
		.clocken1 (1'b1),
		.clocken2 (1'b1),
		.clocken3 (1'b1),
		.data_b ({DATA_WIDTH{1'b1}}),
		.eccstatus (),
		.q_a (),
		.rden_a (1'b1),
		.wren_b (1'b0)
	);

	defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone IV E",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = (1 << ADDRESS_WIDTH),
		altsyncram_component.numwords_b = (1 << ADDRESS_WIDTH),
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.rdcontrol_reg_b = "CLOCK0",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = ADDRESS_WIDTH,
		altsyncram_component.widthad_b = ADDRESS_WIDTH,
		altsyncram_component.width_a = DATA_WIDTH,
		altsyncram_component.width_b = DATA_WIDTH,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.init_file = "bios.fixed.hex";

endmodule

