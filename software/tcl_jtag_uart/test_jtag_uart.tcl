source "jtag_comm.tcl"

proc send_uart_byte {byte} {
	# Clear data
	write_instance_int UARX 0

	# Wait for FPGA to clear its ACK
	while {[read_instance_int UARX] != 0} {}

	# Send byte
	set byte [expr {$byte | 0x100}]
	write_instance_int UARX $byte

	# Wait for FPGA to ACK
	while {[read_instance_int UARX] == 0} {}
}

proc recv_uart_byte {} {
	# Clear ACK
	write_instance_int UATX 0

	# Wait for FPGA to send byte
	while {[read_instance_int UATX] == 0} {}

	# ACK
	set byte [read_instance_int UATX]
	write_instance_int UATX $byte

	return [expr {$byte & 0xFF}]
}


if {[fpga_init] == -1} {
	puts stderr "No FPGAs found."
	exit
}

set fpga_name [get_fpga_name]
puts "FPGA Found: $fpga_name\n\n"



send_uart_byte 12
puts [recv_uart_byte]

send_uart_byte 88
puts [recv_uart_byte]

send_uart_byte 0
puts [recv_uart_byte]


