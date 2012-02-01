/*
 * Based on Milkymist SoC
 * Copyright (C) 2012 William Heatley
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


module lm32_test_top (
	// Clocks
	input		clk50,
	input		clkin_125,

	// Ethernet
	input		enet_rx_clk,
	output		enet_gtx_clk,
	output		enet_mdc,
	inout		enet_mdio,
	output		enet_tx_en,
	input	[3:0] 	enet_rxd,
	output	[3:0] 	enet_txd,
	input		enet_rx_dv,
	output		enet_resetn,

	// LEDs
	output 	[7:0]	led
);

	//// System Clock
	wire sys_clk = clk50;


	//// System Reset
	wire sys_rst;
	safe_virtual_wire # (
		.PROBE_WIDTH(0), .SOURCE_WIDTH(1), .INSTANCE_ID("SRST")
	) sys_rst_vw_blk (
		.rx_clk (sys_clk), .rx_probe(), .tx_source(sys_rst)
	);


	// RAM		0x00000000 (shadow @0x80000000)
	// Debug	0x10000000 (shadow @0x90000000)
	// Ethernet     0x30000000 (shadow @0xb0000000)
	// CSR bridge   0x60000000 (shadow @0xe0000000)
	wire [31:0]	cpuibus_adr,
			cpudbus_adr,
			jtag_adr,
			monitor_adr,
			ebr_adr,
			csrbrg_adr,
			eth_adr;
	
	wire [31:0]	cpuibus_dat_r,
			cpuibus_dat_w,
			cpudbus_dat_r,
			cpudbus_dat_w,
			jtag_dat_r,
			jtag_dat_w,
			eth_dat_r,
			eth_dat_w,
			monitor_dat_r,
			monitor_dat_w,
			csrbrg_dat_r,
			csrbrg_dat_w,
			ebr_dat_w,
			ebr_dat_r;
	
	wire [2:0]	cpuibus_cti,
			cpudbus_cti,
			ebr_cti;

`ifdef CFG_HW_DEBUG_ENABLED
	wire [3:0]	cpuibus_sel;
`endif
	wire [3:0]	cpudbus_sel,
			eth_sel,
			jtag_sel,
			monitor_sel,
			ebr_sel;

`ifdef CFG_HW_DEBUG_ENABLED
	wire		cpuibus_we;
`endif
	wire		csrbrg_we,
			cpudbus_we,
			jtag_we,
			eth_we,
			monitor_we,
			ebr_we;
	
	wire 		cpuibus_cyc,
			cpudbus_cyc,
			jtag_cyc,
			monitor_cyc,
			csrbrg_cyc,
			eth_cyc,
			ebr_cyc;
	
	wire		cpuibus_stb,
			cpudbus_stb,
			jtag_stb,
			monitor_stb,
			csrbrg_stb,
			eth_stb,
			ebr_stb;
	
	wire		cpuibus_ack,
			cpudbus_ack,
			jtag_ack,
			monitor_ack,
			csrbrg_ack,
			eth_ack,
			ebr_ack;
	
	wire		cpuibus_err = 1'b0,
			cpudbus_err = 1'b0;


	conbus5x6 #(
		.s0_addr(3'b000),	// RAM
		.s1_addr(3'b001),	// Debug
		.s2_addr(3'b010),	// XXX
		.s3_addr(3'b011),	// Ethernet
		.s4_addr(2'b10), 	// XXX
		.s5_addr(2'b11)		// CSR
	) wbswitch (
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),

		// Master 0
`ifdef CFG_HW_DEBUG_ENABLED
		.m0_dat_i(cpuibus_dat_w),
`else
		.m0_dat_i(32'hx),
`endif
		.m0_dat_o(cpuibus_dat_r),
		.m0_adr_i(cpuibus_adr),
		.m0_cti_i(cpuibus_cti),
`ifdef CFG_HW_DEBUG_ENABLED
		.m0_we_i(cpuibus_we),
		.m0_sel_i(cpuibus_sel),
`else
		.m0_we_i(1'b0),
		.m0_sel_i(4'hf),
`endif
		.m0_cyc_i(cpuibus_cyc),
		.m0_stb_i(cpuibus_stb),
		.m0_ack_o(cpuibus_ack),

		// Master 1
		.m1_dat_i(cpudbus_dat_w),
		.m1_dat_o(cpudbus_dat_r),
		.m1_adr_i(cpudbus_adr),
		.m1_cti_i(cpudbus_cti),
		.m1_we_i(cpudbus_we),
		.m1_sel_i(cpudbus_sel),
		.m1_cyc_i(cpudbus_cyc),
		.m1_stb_i(cpudbus_stb),
		.m1_ack_o(cpudbus_ack),

		// Master 2
		.m2_dat_i(jtag_dat_w),
		.m2_dat_o(jtag_dat_r),
		.m2_adr_i(jtag_adr),
		.m2_cti_i(3'b111),
		.m2_we_i(jtag_we),
		.m2_sel_i(jtag_sel),
		.m2_cyc_i(jtag_cyc),
		.m2_stb_i(jtag_stb),
		.m2_ack_o(jtag_ack),

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
		.s1_dat_i(monitor_dat_r),
		.s1_dat_o(monitor_dat_w),
		.s1_adr_o(monitor_adr),
		.s1_cti_o(),
		.s1_sel_o(monitor_sel),
		.s1_we_o(monitor_we),
		.s1_cyc_o(monitor_cyc),
		.s1_stb_o(monitor_stb),
		.s1_ack_i(monitor_ack),

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
		.s3_dat_i(eth_dat_r),
		.s3_dat_o(eth_dat_w),
		.s3_adr_o(eth_adr),
		.s3_cti_o(),
		.s3_sel_o(eth_sel),
		.s3_we_o(eth_we),
		.s3_cyc_o(eth_cyc),
		.s3_stb_o(eth_stb),
		.s3_ack_i(eth_ack),		

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
	wb_ebr_ctrl # (
		.SIZE (16384),
		.INIT_FILE ("software/ethernet_test/ethernet_test.mif")
	) ram_blk (
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
	wire [31:0]	csr_dr_gpio,
			csr_dr_jtag_uart,
			csr_dr_sysctl,
			csr_dr_ethernet;

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
		.csr_di(
			csr_dr_gpio
			|csr_dr_jtag_uart
			|csr_dr_sysctl
			|csr_dr_ethernet
		)
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


	//// UART - Debug channel
	uart #(
		.csr_addr (4'h2),
		.JTAG_INSTANCE_ID (0)
	) uart_blk (
		.sys_clk (sys_clk),
		.sys_rst (sys_rst),

		.csr_a(csr_a),
		.csr_we(csr_we),
		.csr_di(csr_dw),
		.csr_do(csr_dr_jtag_uart)
	);


	//// System Controller
	sysctl #(
		.csr_addr(4'h3)
	) sysctl (
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),

		.csr_a(csr_a),
		.csr_we(csr_we),
		.csr_di(csr_dw),
		.csr_do(csr_dr_sysctl)
	);


	//// CPU
	reg ext_break = 0;
	wire ext_break_vw;
	safe_virtual_wire # (.PROBE_WIDTH(0), .SOURCE_WIDTH(1), .INSTANCE_ID("EXTB")) ext_break_vw_blk (.rx_clk (sys_clk), .rx_probe(), .tx_source(ext_break_vw));

	reg old_ext_break = 0;

	always @ (posedge sys_clk)
	begin
		old_ext_break <= ext_break_vw;
		ext_break <= ext_break_vw & !old_ext_break;
	end

	lm32_top cpu(
		.clk_i (sys_clk),
		.rst_i (sys_rst),
		.interrupt (32'h00000000),

		.I_ADR_O(cpuibus_adr),
		.I_DAT_I(cpuibus_dat_r),
`ifdef CFG_HW_DEBUG_ENABLED
		.I_DAT_O(cpuibus_dat_w),
		.I_SEL_O(cpuibus_sel),
`else
		.I_DAT_O(),
		.I_SEL_O(),
`endif
		.I_CYC_O(cpuibus_cyc),
		.I_STB_O(cpuibus_stb),
		.I_ACK_I(cpuibus_ack),
`ifdef CFG_HW_DEBUG_ENABLED
		.I_WE_O(cpuibus_we),
`else
		.I_WE_O(),
`endif
		.I_CTI_O(cpuibus_cti),
		.I_LOCK_O(),
		.I_BTE_O(),
		.I_ERR_I(cpuibus_err),
		.I_RTY_I(1'b0),
`ifdef CFG_EXTERNAL_BREAK_ENABLED
		.ext_break(ext_break),
`endif

		.D_ADR_O(cpudbus_adr),
		.D_DAT_I(cpudbus_dat_r),
		.D_DAT_O(cpudbus_dat_w),
		.D_SEL_O(cpudbus_sel),
		.D_CYC_O(cpudbus_cyc),
		.D_STB_O(cpudbus_stb),
		.D_ACK_I(cpudbus_ack),
		.D_WE_O (cpudbus_we),
		.D_CTI_O(cpudbus_cti),
		.D_LOCK_O(),
		.D_BTE_O(),
		.D_ERR_I(cpudbus_err),
		.D_RTY_I(1'b0)
	);


	//// JTAG
	//// Allows access to the data bus through JTAG.
	jtag jtag_blk (
		.sys_clk (sys_clk),
		.sys_rst (sys_rst),

		.wb_adr_o (jtag_adr),
		.wb_dat_o (jtag_dat_w),
		.wb_dat_i (jtag_dat_r),
		.wb_ack_i (jtag_ack),
		.wb_sel_o (jtag_sel),
		.wb_stb_o (jtag_stb),
		.wb_cyc_o (jtag_cyc),
		.wb_we_o (jtag_we)
	);


	//// Monitor ROM / RAM
	//// Allows debugging of the CPU. When ext_break is triggered, the CPU
	//// jumps here.
	wire debug_write_lock = 1'b1;
`ifdef CFG_ROM_DEBUG_ENABLED
	monitor monitor_blk (
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),
		.write_lock(debug_write_lock),

		.wb_adr_i(monitor_adr),
		.wb_dat_o(monitor_dat_r),
		.wb_dat_i(monitor_dat_w),
		.wb_sel_i(monitor_sel),
		.wb_stb_i(monitor_stb),
		.wb_cyc_i(monitor_cyc),
		.wb_ack_o(monitor_ack),
		.wb_we_i(monitor_we)
	);
`else
	assign monitor_dat_r = 32'bx;
	assign monitor_ack = 1'b0;
`endif
		
	
	//// Ethernet
	wire eth_tx_clk;
	eth_clk_div eth_clk_div_blk (
		.rx_clk125 (clkin_125),
		.tx_clk (eth_tx_clk)
	);

	minimac2 # (
		.csr_addr (4'h8)
	) ethernet (
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),

		.csr_a(csr_a),
		.csr_we(csr_we),
		.csr_di(csr_dw),
		.csr_do(csr_dr_ethernet),

		.irq_rx(),
		.irq_tx(),

		.wb_adr_i(eth_adr),
		.wb_dat_o(eth_dat_r),
		.wb_dat_i(eth_dat_w),
		.wb_sel_i(eth_sel),
		.wb_stb_i(eth_stb),
		.wb_cyc_i(eth_cyc),
		.wb_ack_o(eth_ack),
		.wb_we_i(eth_we),

		.phy_tx_clk(eth_tx_clk),
		.phy_tx_data(enet_txd),
		.phy_tx_en(enet_tx_en),
		.phy_rx_clk(enet_rx_clk),
		.phy_rx_data(enet_rxd),
		.phy_dv(enet_rx_dv),
		.phy_mii_clk(enet_mdc),
		.phy_mii_data(enet_mdio),
		.phy_rst_n(enet_resetn)		
	);

	assign enet_gtx_clk = eth_tx_clk;


endmodule

