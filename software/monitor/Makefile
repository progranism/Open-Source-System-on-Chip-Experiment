OBJECTS=monitor.o
SEGMENTS=-j .text -j .data -j .rodata
CC=lm32-elf-gcc
LD=lm32-elf-ld
OBJCOPY=lm32-elf-objcopy

LDFLAGS = -nostdlib -nodefaultlibs
INCLUDES_NOLIBC ?= -nostdinc
INCLUDES = $(INCLUDES_NOLIBC)
CFLAGS = -O9 -Wall -Wstrict-prototypes -Wold-style-definition -Wshadow \
	 -mbarrel-shift-enabled -mmultiply-enabled \
	 -msign-extend-enabled -fno-builtin -fsigned-char \
	 -fsingle-precision-constant $(INCLUDES)


all: monitor.bin monitor.rom

%.bin: %.elf
	$(OBJCOPY) $(SEGMENTS) -O binary $< $@

monitor.rom: monitor.bin
	../../tools/bin2hex $< $@ 512

monitor.elf: linker.ld $(OBJECTS)
	$(LD) $(LDFLAGS) -T linker.ld -N -o $@ $(OBJECTS)

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o monitor.elf monitor.bin monitor.rom .*~ *~ Makefile.bak

