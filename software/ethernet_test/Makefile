MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS=crt0.o main.o console.o libc.o vsnprintf-nofloat.o divsi3.o mdio.o microudp.o crc32.o
SEGMENTS=-j .text -j .data -j .rodata
LIBS=

# Disable optimizations so we can debug
CFLAGS += -O0 -g

all: ethernet_test.mif

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@

%.mif: %.bin
	../../tools/bin2mif $< $@ 8192

ethernet_test.elf: linker.ld $(OBJECTS) $(LIBS)

%.elf:
	$(LD) $(LDFLAGS) -T $< -N -o $@ $(OBJECTS)

.PHONY: clean depend $(LIBS)

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o ethernet_test.elf ethernet_test.bin ethernet_test.mif .*~ *~ Makefile.bak

