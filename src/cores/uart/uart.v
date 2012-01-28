// Allows UART-like communication to any external device that
// can read our memory. Currently used in combination with the JTAG module.
//
//
// HOST SIDE - Send Byte:
// while (UARX != 0);	// Wait for buffer to be empty
// UARX = byte | 0x100;	// Send
//
// HOST SIDE - Receive Byte:
// while (UATX == 0);	// Wait for data
// byte = UATX & 0xFF;	// Read data
// UATX = 0;	// Clear buffer
//
//
// CPU SIDE - Send Byte:
// while (UATX != 0);	// Wait for buffer to be empty
// UATX = byte | 0x100;	// Send
//
// CPU SIDE - Receive Byte:
// while (UARX == 0);	// Wait for data
// byte = UARX & 0xFF;	// Read data
// UARX = 0;		// Clear buffer
//
// 


module uart #(
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

	reg [31:0] rx_reg = 32'd0, tx_reg = 32'd0;


	always @ (posedge sys_clk)
	begin
		if (sys_rst)
		begin
			csr_do <= 32'd0;

			rx_reg <= 32'd0;
			tx_reg <= 32'd0;
		end
		else
		begin
			csr_do <= 32'd0;

			if (csr_selected)
			begin
				if (csr_we)
				begin
					case (csr_a[3:0])
						4'b0000: rx_reg <= csr_di[31:0];
						4'b0001: tx_reg <= csr_di[31:0];
					endcase
				end

				case(csr_a[3:0])
					4'b0000: csr_do <= rx_reg;
					4'b0001: csr_do <= tx_reg;
				endcase
			end
		end
	end

endmodule

