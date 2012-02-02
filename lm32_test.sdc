create_clock -period 20.000 -name clk50 clk50
create_clock -period 8.000 -name clkin_125 clkin_125

create_clock -period "25MHz" -name enet_rx_clkc [get_ports enet_rx_clk]
create_clock -name enet_rx_clkc_virt -period "25MHz"

#create_clock -period 40.000 -name enet_rx_clk enet_rx_clk

derive_pll_clocks
derive_clock_uncertainty


##
#set_multicycle_path 0 -setup -end -rise_from [get_clocks enet_rx_clkc_virt] -rise_to \ 
#[get_clocks {enet_rx_clkc}]
#set_multicycle_path 0 -setup -end -fall_from [get_clocks enet_rx_clkc_virt] -fall_to \ 
#[get_clocks {enet_rx_clkc}]

set_input_delay -min -0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports {enet_rxd[*]}]
set_input_delay -min -0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports enet_rx_dv]

set_input_delay -max 0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports {enet_rxd[*]}]
set_input_delay -max 0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports enet_rx_dv]


