// Allows UART-like communication over JTAG on Altera devices
//
//
// On the host side, here's how to send bytes:
// Set UARX to 0
// Loop until UARX reads as 0
// Write desired byte to UARX, | (0x100)
// Loop until UARX reads as not 0
//
// On the host side, to receive bytes:
// Set UATX to 0
// Loop until UATX is not 0
// Received byte = UATX & 0xFF
// Set UATX to not 0
//
// 
// On our side, to receive a byte:
// Loop until 0x0000 is 0
// Set 0x0001 to 0
// Loop until 0x0000 is not 0
// Received byte is 0x0000 & 0xFF
// Set 0x0001 to 1
//
// On our side, to send a byte:
// Set 0x0002 to 0
// Loop until 0x0003 is 0
// Set 0x0002 to desired byte | 0x100
// Loop until 0x0003 is not 0


module jtag_uart #(
	parameter csr_addr = 4'h0
) (
	input sys_clk,
	input sys_rst,

	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output reg [31:0] csr_do
);

	wire csr_selected = csr_a[13:10] == csr_addr;

	wire [31:0] rx_data_from_host, host_ack;
	reg [31:0] my_ack = 0, tx_data_to_host = 0;
	
	virtual_wire # (.PROBE_WIDTH(32), .WIDTH(32), .INSTANCE_ID("UARX")) rx_vw_blk (.probe(my_ack), .source(rx_data_from_host));

	virtual_wire # (.PROBE_WIDTH(32), .WIDTH(32), .INSTANCE_ID("UATX")) tx_vw_blk (.probe(tx_data_to_host), .source(host_ack));


	always @ (posedge sys_clk)
	begin
		if (sys_rst)
		begin
			csr_do <= 32'd0;

			my_ack <= 32'd0;
			tx_data_to_host <= 32'd0;
		end
		else
		begin
			csr_do <= 32'd0;

			if (csr_selected)
			begin
				if (csr_we)
				begin
					case (csr_a[3:0])
						4'b0001: my_ack <= csr_di[31:0];
						4'b0010: tx_data_to_host <= csr_di[31:0];
					endcase
				end

				case(csr_a[3:0])
					4'b0000: csr_do <= rx_data_from_host;
					4'b0001: csr_do <= my_ack;
					4'b0010: csr_do <= tx_data_to_host;
					4'b0011: csr_do <= host_ack;
				endcase
			end
		end
	end

endmodule

