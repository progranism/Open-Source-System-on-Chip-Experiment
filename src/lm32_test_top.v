module lm32_test_top (
	input clk50,

	output [7:0] led
);

	wire rst_vw;
	virtual_wire # (.PROBE_WIDTH(0), .WIDTH(1), .INSTANCE_ID("RSET")) rst_vw_blk (.probe(), .source(rst_vw));

	// Ethernet	0x10000000 (shadow @0xb0000000)
	// CSR bridge   0x60000000 (shadow @0xe0000000)
	wire sys_rst = ~rst_vw;
	wire sys_clk = clk50;

	wire [31:0]	ebr_adr,
			csrbrg_adr;
	
	wire [31:0]	cpuibus_dat_r,
			csrbrg_dat_r,
			csrbrg_dat_w,
			ebr_dat_w,
			ebr_dat_r;
	
	wire		ebr_cti;

	wire [3:0]	ebr_sel;

	wire		csrbrg_we,
			ebr_we;
	
	wire 		csrbrg_cyc,
			ebr_cyc;
	
	wire		csrbrg_stb,
			ebr_stb;
	
	wire		cpuibus_ack,
			csrbrg_ack,
			ebr_ack;


	conbus5x6 #(
		.s0_addr(3'b000),	// RAM
		.s5_addr(2'b11)		// CSR
	) wbswitch (
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),

		// Master 0
		.m0_dat_i(cpuibus_dat_w),
		.m0_dat_o(cpuibus_dat_r),
		.m0_adr_i(cpuibus_adr),
		.m0_cti_i(),
		.m0_we_i(cpuibus_we),
		.m0_sel_i(4'hf),
		.m0_cyc_i(cpuibus_cyc),
		.m0_stb_i(cpuibus_stb),
		.m0_ack_o(cpuibus_ack),

		// Master 1
		.m1_dat_i(),
		.m1_dat_o(),
		.m1_adr_i(),
		.m1_cti_i(),
		.m1_we_i(1'b0),
		.m1_sel_i(4'hf),
		.m1_cyc_i(1'b0),
		.m1_stb_i(1'b0),
		.m1_ack_o(),

		// Master 2
		.m2_dat_i(),
		.m2_dat_o(),
		.m2_adr_i(),
		.m2_cti_i(),
		.m2_we_i(1'b0),
		.m2_sel_i(4'hf),
		.m2_cyc_i(1'b0),
		.m2_stb_i(1'b0),
		.m2_ack_o(),

		// Master 3
		.m3_dat_i(),
		.m3_dat_o(),
		.m3_adr_i(),
		.m3_cti_i(),
		.m3_we_i(1'b0),
		.m3_sel_i(4'hf),
		.m3_cyc_i(1'b0),
		.m3_stb_i(1'b0),
		.m3_ack_o(),

		// Master 4
		.m4_dat_i(),
		.m4_dat_o(),
		.m4_adr_i(),
		.m4_cti_i(),
		.m4_we_i(1'b0),
		.m4_sel_i(4'hf),
		.m4_cyc_i(1'b0),
		.m4_stb_i(1'b0),
		.m4_ack_o(),

		// Slave 0
		.s0_dat_i(ebr_dat_w),
		.s0_dat_o(ebr_dat_r),
		.s0_adr_o(ebr_adr),
		.s0_cti_o(ebr_cti),
		.s0_sel_o(ebr_sel),
		.s0_we_o(ebr_we),
		.s0_cyc_o(ebr_cyc),
		.s0_stb_o(ebr_stb),
		.s0_ack_i(ebr_ack),

		// Slave 1
		.s1_dat_i(),
		.s1_dat_o(),
		.s1_adr_o(),
		.s1_cti_o(),
		.s1_sel_o(),
		.s1_we_o(),
		.s1_cyc_o(),
		.s1_stb_o(),
		.s1_ack_i(1'b0),

		// Slave 2
		.s2_dat_i(),
		.s2_dat_o(),
		.s2_adr_o(),
		.s2_cti_o(),
		.s2_sel_o(),
		.s2_we_o(),
		.s2_cyc_o(),
		.s2_stb_o(),
		.s2_ack_i(1'b0),

		// Slave 3
		.s3_dat_i(),
		.s3_dat_o(),
		.s3_adr_o(),
		.s3_cti_o(),
		.s3_sel_o(),
		.s3_we_o(),
		.s3_cyc_o(),
		.s3_stb_o(),
		.s3_ack_i(1'b0),

		// Slave 4
		.s4_dat_i(),
		.s4_dat_o(),
		.s4_adr_o(),
		.s4_cti_o(),
		.s4_sel_o(),
		.s4_we_o(),
		.s4_cyc_o(),
		.s4_stb_o(),
		.s4_ack_i(1'b0),

		// Slave 5
		.s5_dat_i(csrbrg_dat_r),
		.s5_dat_o(csrbrg_dat_w),
		.s5_adr_o(csrbrg_adr),
		.s5_cti_o(),
		.s5_sel_o(),
		.s5_we_o(csrbrg_we),
		.s5_cyc_o(csrbrg_cyc),
		.s5_stb_o(csrbrg_stb),
		.s5_ack_i(csrbrg_ack)
	);


	//// RAM
	wb_ebr_ctrl # (.SIZE (4096)) ram_blk (
		.CLK_I (sys_clk),
		.RST_I (sys_rst),
		.EBR_ADR_I (ebr_adr),
		.EBR_DAT_I (ebr_dat_r),
		.EBR_WE_I (ebr_we),
		.EBR_CYC_I (ebr_cyc),
		.EBR_STB_I (ebr_stb),
		.EBR_SEL_I (ebr_sel),
		.EBR_CTI_I (ebr_cti),
		.EBR_BTE (),
		.EBR_LOCK_I (),
		.EBR_DAT_O (ebr_dat_w),
		.EBR_ACK_O (ebr_ack),
		.EBR_ERR_O (),
		.EBR_RTY_O ()
	);


	//// CSR Bridge
	wire [13:0]	csr_a;
	wire		csr_we;
	wire [31:0]	csr_dw;
	wire [31:0]	csr_dr_gpio;

	csrbrg csrbrg (
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),

		.wb_adr_i(csrbrg_adr),
		.wb_dat_i(csrbrg_dat_w),
		.wb_dat_o(csrbrg_dat_r),
		.wb_cyc_i(csrbrg_cyc),
		.wb_stb_i(csrbrg_stb),
		.wb_we_i(csrbrg_we),
		.wb_ack_o(csrbrg_ack),

		.csr_a(csr_a),
		.csr_we(csr_we),
		.csr_do(csr_dw),
		.csr_di(csr_dr_gpio)
	);


	//// GPIO
	wire [31:0] gpio_leds;

	gpio #(
		.csr_addr(4'h1)
	) gpio (
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),

		.csr_a(csr_a),
		.csr_we(csr_we),
		.csr_di(csr_dw),
		.csr_do(csr_dr_gpio),

		.gpio_outputs(gpio_leds)
	);

	assign led = gpio_leds[23:16];
	virtual_wire # (.PROBE_WIDTH(32), .WIDTH(0), .INSTANCE_ID("GPIO")) gpio_vw_blk (.probe(gpio_leds), .source());



	//// CPU
	reg [31:0]	cpuibus_adr = 0, cpuibus_dat_w = 0;
	reg cpuibus_we = 0, cpuibus_cyc = 0, cpuibus_stb = 0;
	reg [31:0] cpu_r0 = 0;

	reg [31:0] cpu_state = 0;

	
	always @ (posedge sys_clk)
	begin
		if (sys_rst)
			cpu_state = 0;
		else
		begin
		case(cpu_state)
			0: cpu_state = 1;
			1: cpu_state = 2;
			2: begin
				cpuibus_we = 0;
				cpuibus_adr = 32'h00000000;
				cpuibus_cyc = 1;
				cpuibus_stb = 1;
				cpu_state = 3;
			end
			3: begin
				if (cpuibus_ack)
				begin
					cpu_r0 = cpuibus_dat_r;
					cpuibus_cyc = 0;
					cpuibus_stb = 0;
					cpu_state = 4;
				end
			end
			4: begin
				cpuibus_we = 1;
				cpuibus_adr = 32'h00000000;
				cpuibus_dat_w = cpu_r0 + 1;
				cpuibus_cyc = 1;
				cpuibus_stb = 1;
				cpu_state = cpu_state + 1;
			end
			5: begin
				if (cpuibus_ack)
				begin
					cpuibus_cyc = 0;
					cpuibus_stb = 0;
					cpu_state = cpu_state + 1;
				end
			end
			6: begin
				cpuibus_we = 1;
				cpuibus_adr = 32'h60001004;
				cpuibus_dat_w = cpu_r0;
				cpuibus_cyc = 1;
				cpuibus_stb = 1;
				cpu_state = cpu_state + 1;
			end
			7: begin
				if (cpuibus_ack)
				begin
					cpuibus_cyc = 0;
					cpuibus_stb = 0;
					cpu_state = cpu_state + 1;
				end
			end
			8: cpu_state = 0;
		endcase
		end
	end

endmodule

