MMDIR=../..
include $(MMDIR)/software/include.mak

OBJECTS_ALL=divsi3.o libc.o crc32.o console.o uart.o
OBJECTS=$(OBJECTS_ALL)
OBJECTS_LIGHT=$(OBJECTS_ALL) vsnprintf-nofloat.o

all: libbase-light.a libbase.a

libbase-light.a: $(OBJECTS_LIGHT)
	$(AR) clr libbase-light.a $(OBJECTS_LIGHT)
	$(RANLIB) libbase-light.a

libbase.a: $(OBJECTS)
	$(AR) clr libbase.a $(OBJECTS)
	$(RANLIB) libbase.a

.PHONY: clean depend

depend:
	makedepend -Y -- $(CFLAGS) -- *.c

clean:
	rm -f *.o libbase.a libbase-light.a .*~ *~ Makefile.bak

