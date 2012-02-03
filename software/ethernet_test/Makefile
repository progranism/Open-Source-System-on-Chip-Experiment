MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS=crt0.o main.o
SEGMENTS=-j .text -j .data -j .rodata
LIBS=$(MMDIR)/software/libbase/libbase-light.a $(MMDIR)/software/libnet/libnet.a

# Disable optimizations so we can debug
CFLAGS += -O0 -g

all: ethernet_test.mif

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@

%.mif: %.bin
	../../tools/bin2mif $< $@ 8192

ethernet_test.elf: linker.ld $(OBJECTS) $(LIBS)

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
	rm -f *.o ethernet_test.elf ethernet_test.bin ethernet_test.mif .*~ *~ Makefile.bak

