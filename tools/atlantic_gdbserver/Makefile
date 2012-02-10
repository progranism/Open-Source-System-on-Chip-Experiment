all: atlantic_gdbserver.exe

atlantic_gdbserver.exe: atlantic_gdbserver.c
	g++ -Wl,--add-stdcall-alias -g atlantic_gdbserver.c libjtag_atlantic.a -lws2_32 -o atlantic_gdbserver.exe


