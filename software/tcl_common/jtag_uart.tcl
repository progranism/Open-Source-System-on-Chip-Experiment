proc uart_send_byte {byte} {
	set byte [expr {$byte & 0xFF}]

	# Wait for buffer to be empty
	while {[jtag_read_word 0x60002000] != 0} {}

	# Send byte
	jtag_write_word 0x60002000 [expr {$byte | 0x100}]
}

proc uart_can_send {} {
	return [expr {[jtag_read_word 0x60002000] == 0}]
}

proc uart_recv_byte {} {
	# Wait for buffer to be full
	while {[jtag_read_word 0x60002004] == 0} {}

	# Read
	set byte [jtag_read_word 0x60002004]

	# Clear buffer
	jtag_write_word 0x60002004 0

	return [expr {$byte & 0xFF}]
}

proc uart_can_read {} {
	return [expr {[jtag_read_word 0x60002004] != 0}]
}

