source "jtag_comm.tcl"
source "jtag_memory_bridge.tcl"


# Find the FPGA and get it ready
if {[fpga_init] == -1} {
	puts stderr "No FPGAs found."
	exit
}

set fpga_name [get_fpga_name]
puts "FPGA Found: $fpga_name\n\n"

puts "Reading the first three words of Monitor ROM..."
puts [format "%.08X" [jtag_read_word 0x10000000]]
puts [format "%.08X" [jtag_read_word 0x10000004]]
puts [format "%.08X" [jtag_read_word 0x10000008]]

puts "\nWriting 0x41424344 to 0x00000080 and reading back...\n"
jtag_write_word 0x00000080 0x41424344
jtag_read_word 0x00000084
puts [format "%.08X" [jtag_read_word 0x00000080]]


