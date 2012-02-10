MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS=crt0.o gdbstub.o
SEGMENTS=-j .text -j .data -j .rodata

# override optimization flags
CFLAGS+=-Os

all: gdbstub.elf gdbstub.bin gdbstub.mif

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@

%.mif: %.bin
	$(MMDIR)/tools/bin2mif $< $@ 2048

gdbstub.elf: linker.ld $(OBJECTS)
	$(LD) $(LDFLAGS) -T linker.ld -N -o $@ $(OBJECTS)
	chmod -x $@

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o gdbstub.elf gdbstub.bin gdbstub.rom .*~ *~ Makefile.bak


