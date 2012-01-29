source "../tcl_common/jtag_comm.tcl"
source "../tcl_common/jtag_memory_bridge.tcl"
source "../tcl_common/jtag_uart.tcl"


proc Server {channel clientaddr clientport} {
	puts "Connection from $clientaddr registered"

	fconfigure $channel -blocking 0
	fconfigure $channel -translation binary

	set trying_to_send 0

	while {1} {
		if {[uart_can_send]} {
			set x [read $channel 1]

			if {[string length $x] != 0} {
				puts [string length $x]
				puts "Received from socket: '$x'"
				set x [scan $x %c]
				puts "Sending '$x'"
				uart_send_byte $x
				#puts "Sent to FPGA"
			}
		}

		if {[uart_can_read]} {
			#puts "Receiving data from the FPGA..."
			set x [uart_recv_byte]
			set x [format "%c" $x]
			
			#puts "Sent from FPGA: $x"
			puts -nonewline $channel $x
			flush $channel
		}

		update
	}

	close $channel
}


# Find the FPGA and get it ready
if {[fpga_init] == -1} {
	puts stderr "No FPGAs found."
	exit
}

set fpga_name [get_fpga_name]
puts "FPGA Found: $fpga_name\n\n"

# Start the GDB Server
socket -server Server 9900
vwait forever


