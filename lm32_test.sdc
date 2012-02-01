create_clock -period 20.000 -name clk50 clk50
create_clock -period 8.000 -name clkin_125 clkin_125

create_clock -period "25MHz" -name enet_rx_clkc [get_ports enet_rx_clk]
create_clock -name enet_rx_clkc_virt -period "25MHz"

#create_clock -period 40.000 -name enet_rx_clk enet_rx_clk

derive_pll_clocks
derive_clock_uncertainty


# Currently assuming that RXD is invalid from -1.0ns to 1.0ns surrounding the
# rising edge of RX_CLK.
#set_input_delay -min -1.0 -clock "enet_rx_clkc_virt" [get_ports {enet_rxd[*]}]

#set_input_delay -max 1.0 -clock "enet_rx_clkc_virt" [get_ports {enet_rxd[*]}]


