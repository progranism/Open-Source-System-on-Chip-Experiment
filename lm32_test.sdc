create_clock -period 20.000 -name clk50 clk50
create_clock -period 8.000 -name clkin_125 clkin_125
create_clock -period 40.000 -name enet_rx_clk enet_rx_clk

derive_pll_clocks
derive_clock_uncertainty
