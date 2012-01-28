proc jtag_read_word {address} {
	# Clear requests
	write_instance_int JBUS 0

	# Wait for FPGA to be ready
	while {[read_instance_int JBUS] != 0} {}

	# Send request
	set x [expr {(1 << 65) | (($address & 0xFFFFFFFF) << 32)}]
	write_instance_int JBUS $x

	# Wait for request to finish
	while {1} {
		set x [read_instance_int JBUS]

		if {$x != 0} {
			return [expr {$x & 0xFFFFFFFF}]
		}
	}
}

proc jtag_write_word {address data} {
	# Clear requests
	write_instance_int JBUS 0

	# Wait for FPGA to be ready
	while {[read_instance_int JBUS] != 0} {}

	# Send request
	write_instance_int JBUS [expr {(3 << 64) | (($address & 0xFFFFFFFF) << 32) | ($data & 0xFFFFFFFF)}]

	# Wait for write to finish
	while {[read_instance_int JBUS] == 0} {}
}


