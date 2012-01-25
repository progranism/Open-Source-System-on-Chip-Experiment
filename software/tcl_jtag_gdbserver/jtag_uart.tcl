proc send_uart_byte {byte} {
	set byte [expr {$byte & 0xFF}]

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

proc send_uart_word {word} {
	send_uart_byte $word
	send_uart_byte [expr {$word >> 8}]
	send_uart_byte [expr {$word >> 16}]
	send_uart_byte [expr {$word >> 24}]
}

proc recv_uart_word {} {
	set a [recv_uart_byte]
	set b [recv_uart_byte]
	set c [recv_uart_byte]
	set d [recv_uart_byte]

	return [expr {($d << 24) | ($c << 16) | ($b << 8) | $a}]
}

