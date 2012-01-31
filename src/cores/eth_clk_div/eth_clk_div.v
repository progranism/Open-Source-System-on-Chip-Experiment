
// Currently this only spits out a 2.5MHz clock for 10Mbps ethernet
module eth_clk_div (
	input rx_clk125,
	output reg tx_clk /* synthesis ALTERA_ATTRIBUTE="PRESERVE_REGISTER=ON" */
);

	reg [5:0] counter = 6'd0;
	reg gen_clk = 1'b0;

	// counter:	0 1 2 3 4
	// clock:	1 1 0 0 0
	always @ (posedge rx_clk125)
	begin
		if (counter >= 6'd4)
			counter <= 6'd0;
		else
			counter <= counter + 6'd1;

		gen_clk <= counter < 6'd2;
	end

	always @ (gen_clk or rx_clk125)
		tx_clk <= gen_clk;

endmodule

