MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS=crt0.o main.o isr.o
SEGMENTS=-j .text -j .data -j .rodata
LIBS=$(MMDIR)/software/libbase/libbase-light.a $(MMDIR)/software/libnet/libnet.a

# Disable optimizations so we can debug
CFLAGS += -O0 -g

all: bios.mif

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@

%.mif: %.bin
	../../tools/bin2mif $< $@ 8192

bios.elf: linker.ld $(OBJECTS) $(LIBS)

%.elf:
	$(LD) $(LDFLAGS) -T $< -N -o $@ $(OBJECTS) -L$(MMDIR)/software/libbase -L$(MMDIR)/software/libnet --start-group -lbase-light -lnet --end-group

$(MMDIR)/software/libbase/libbase-light.a:
	make -C $(MMDIR)/software/libbase/

$(MMDIR)/software/libnet/libnet.a:
	make -C $(MMDIR)/software/libnet/

.PHONY: clean depend $(LIBS)

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o bios.elf bios.bin bios.mif .*~ *~ Makefile.bak

