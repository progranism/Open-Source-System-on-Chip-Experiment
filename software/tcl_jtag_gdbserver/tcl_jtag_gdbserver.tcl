source "jtag_comm.tcl"
source "jtag_uart.tcl"


# r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16,
# r17, r18, r19, r20, r21, r22, r23, r24, r25, gp, fp, sp, ra, ea, ba
set regs [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31]
set PC 64


proc calculate_checksum {packet_data} {
	set sum 0

	foreach char [split $packet_data ""] {
		set sum [expr {$sum + [scan $char %c]}]
	}

	return [expr {$sum & 0xFF}]
}

proc read_packet {channel} {
	set packet_data ""
	set checksum 0

	while {1} {
		set x [read $channel 1]

		if {![string equal $x "\$"] && [string length $packet_data] == 0} {
			puts "Received strange character: $x"
			return 0
		}

		if {[string equal $x #]} {
			break
		} else {
			set packet_data "${packet_data}${x}"
		}
	}

	# Read checksum
	set checksum [read $channel 2]

	# TODO: Check the checksum
	
	return $packet_data
}

proc send_packet {channel packet_data} {
	set checksum [calculate_checksum $packet_data]

	#puts "Packet: $packet_data; Checksum: $checksum"

	set checksum [format %02X $checksum]

	#puts "Checksum: $checksum"

	puts "\$$packet_data#$checksum"
	puts -nonewline $channel "\$$packet_data#$checksum"
	flush $channel

	#while {1} {
	#	puts -nonewline [read $channel 1]
	#}

	if {[string equal [read $channel 1] "+"]} {
		puts "Packet sent succesfully."
	} else {
		puts "Packet send failed. Should retry."
	}
}

# Format num into an 8 digit hex string, in LM32 endianness and such
proc format_word {num} {
	return [format %08X $num]
}

proc read_register {id} {
	global regaddr

	# R0 is always 0
	if {$id == 0} {
		return 0;
	}

	puts "Reading register $id"

	send_uart_byte 9
	send_uart_word [expr {$regaddr + ($id * 4)}]

	return [recv_uart_word]
}

proc read_PC {} {
	global regaddr

	puts "Reading PC"

	send_uart_byte 9
	send_uart_word [expr {$regaddr + 128}]

	return [recv_uart_word]
}

proc handle_cmd_g {channel} {
	global regs
	set response ""

	for {set i 0} {$i < 32} {incr i} {
		set reg [read_register $i]
		set x [format_word $reg]
		set response "${response}${x}"
	}

	send_packet $channel $response
}

proc Server {channel clientaddr clientport} {
	puts "Connection from $clientaddr registered"

	while {1} {
		set cmd [read_packet $channel]

		if {$cmd == 0} {
			continue
		}

		puts -nonewline $channel "+"
		flush $channel

		puts "New command: $cmd"

		if {[string equal $cmd "\$qC"]} {
			send_packet $channel "QC440"
		} elseif {[string equal $cmd "\$?"]} {
			send_packet $channel "T0505:38fb1800;04:0cfb1800;08:2c0f2977;thread:440;"
		} elseif {[string equal $cmd "\$p20"]} {
			send_packet $channel [format_word [read_PC]]
		} elseif {[string equal $cmd "\$g"]} {
			handle_cmd_g $channel
		} else {
			send_packet $channel ""
		}

		#puts -nonewline $channel "\$PacketSize=3fff;QPassSignals+;qXfer:libraries:read+;qXfer:features:read+;QStartNoAckMode+;qXfer:threads:read+#45"
		#send_packet $channel ""
		#puts -nonewline $channel "\$#00"
		#flush $channel
	}

	#puts $channel [clock format [clock seconds]]
	close $channel
}


# Find the FPGA and get it ready
if {[fpga_init] == -1} {
	puts stderr "No FPGAs found."
	exit
}

set fpga_name [get_fpga_name]
puts "FPGA Found: $fpga_name\n\n"

# Make sure the Debug Monitor is running
if {[recv_uart_byte] != 0x54} {
	puts stderr "ERROR: The Debug Monitor isn't running."
	exit
}

# Fetch the Register Start Address
send_uart_byte 1
set regaddr [recv_uart_word]

puts [format "Register Start Address = %.8X" $regaddr]


# TEST #
send_uart_byte 9
send_uart_word $regaddr
puts [recv_uart_word]


# Start the GDB Server
socket -server Server 9900
vwait forever



##send_uart_byte 12
##puts [recv_uart_byte]
##
##send_uart_byte 88
##puts [recv_uart_byte]
##
##send_uart_byte 0
##puts [recv_uart_byte]


