fin = open("monitor.hex", "r")
fout = open("monitor.fixed.hex", "w")

for line in fin:
	checksum = line[-3:]
	checksum = (0x100 - int(checksum, 16)) & 0xFF

	count = int(line[1:3], 16)
	address = int(line[3:7], 16)

	if count == 0:
		fout.write(line)
		break

	checksum = checksum - (address & 0xFF) - ((address >> 8) & 0xFF)
	print checksum
	address = address >> 2
	checksum += (address & 0xFF) + ((address >> 8) & 0xFF)
	print checksum

	checksum = (0x100 - (checksum & 0xFF)) & 0xFF
	print checksum

	#print line[:3]
	print ("%04X" % address)
	#print line[7:-2]

	line = line[:3] + ("%04X" % address) + line[7:-3] + ("%02X" % checksum)
	#line[3:7] = "%04X" % address
	#line[-2:] = "%02X" % checksum

	fout.write(line + "\n")

	#break

