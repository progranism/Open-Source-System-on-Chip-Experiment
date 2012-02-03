create_clock -period 20.000 -name clk50 clk50
create_clock -period 8.000 -name clkin_125 clkin_125

create_clock -period "25MHz" -name enet_rx_clkc [get_ports enet_rx_clk]
create_clock -name enet_rx_clkc_virt -period "25MHz"

#create_clock -period 40.000 -name enet_rx_clk enet_rx_clk

derive_pll_clocks
derive_clock_uncertainty


create_generated_clock -name enet_tx_clkc -source [get_pins {eth_clk_div:eth_clk_div_blk|tx_clk90}] [get_ports {enet_gtx_clk}]


##
#set_multicycle_path 0 -setup -end -rise_from [get_clocks enet_rx_clkc_virt] -rise_to \ 
#[get_clocks {enet_rx_clkc}]
#set_multicycle_path 0 -setup -end -fall_from [get_clocks enet_rx_clkc_virt] -fall_to \ 
#[get_clocks {enet_rx_clkc}]

set_input_delay -min -0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports {enet_rxd[*]}]
set_input_delay -min -0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports enet_rx_dv]

set_input_delay -max 0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports {enet_rxd[*]}]
set_input_delay -max 0.5 -clock [get_clocks enet_rx_clkc_virt] [get_ports enet_rx_dv]



set_output_delay -clock enet_tx_clkc -max 1.0 [get_ports {enet_txd[*]}]
set_output_delay -clock enet_tx_clkc -max 1.0 [get_ports {enet_tx_en}]

set_output_delay -clock enet_tx_clkc -min -0.8 [get_ports {enet_txd[*]}]
set_output_delay -clock enet_tx_clkc -min -0.8 [get_ports {enet_tx_en}]


