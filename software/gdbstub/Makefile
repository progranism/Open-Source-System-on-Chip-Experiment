OBJECTS=crt0.o gdbstub.o
SEGMENTS=-j .text -j .data -j .rodata
CC=lm32-elf-gcc
LD=lm32-elf-ld
OBJCOPY=lm32-elf-objcopy

LDFLAGS = -nostdlib -nodefaultlibs
INCLUDES_NOLIBC ?= -nostdinc
INCLUDES = $(INCLUDES_NOLIBC) -I.
CFLAGS = -O9 -Wall -Wstrict-prototypes -Wold-style-definition -Wshadow \
	 -mbarrel-shift-enabled -mmultiply-enabled \
	 -msign-extend-enabled -fno-builtin -fsigned-char \
	 -fsingle-precision-constant $(INCLUDES)

CFLAGS+=-Os

all: gdbstub.elf gdbstub.bin gdbstub.mif

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@

%.mif: %.bin
	../../tools/bin2mif $< $@ 2048

gdbstub.elf: linker.ld $(OBJECTS)
	$(LD) $(LDFLAGS) -T linker.ld -N -o $@ $(OBJECTS)

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o gdbstub.elf gdbstub.bin gdbstub.mif .*~ *~ Makefile.bak

