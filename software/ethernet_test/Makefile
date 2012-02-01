OBJECTS=crt0.o main.o console.o libc.o vsnprintf-nofloat.o divsi3.o mdio.o
SEGMENTS=-j .text -j .data -j .rodata
CC=lm32-elf-gcc
LD=lm32-elf-ld
OBJCOPY=lm32-elf-objcopy

LDFLAGS = -nostdlib -nodefaultlibs
INCLUDES_NOLIBC ?= -nostdinc
INCLUDES = $(INCLUDES_NOLIBC) -I../include -I../include/base
CFLAGS = -O9 -Wall -Wstrict-prototypes -Wold-style-definition -Wshadow \
	 -mbarrel-shift-enabled -mmultiply-enabled -mdivide-enabled \
	 -msign-extend-enabled -fno-builtin -fsigned-char \
	 -fsingle-precision-constant $(INCLUDES)

CFLAGS+=-g

all: ethernet_test.elf ethernet_test.bin ethernet_test.mif

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@

%.mif: %.bin
	../../tools/bin2mif $< $@ 4096

ethernet_test.elf: linker.ld $(OBJECTS)
	$(LD) $(LDFLAGS) -T linker.ld -N -o $@ $(OBJECTS)

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o ethernet_test.elf ethernet_test.bin ethernet_test.mif .*~ *~ Makefile.bak

