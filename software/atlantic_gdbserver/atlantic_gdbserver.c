#include <stdio.h>
#include <windows.h>
#include <winsock2.h>
#include "my_jtag_atlantic.h"
#include "fcntl.h"


int main (int argc, char *argv[])
{
	JTAGATLANTIC *link;
	SOCKET server, client;
	WSADATA wsaData;
	sockaddr_in local, from;
	u_long iMode = 1;
	int from_len = sizeof(from), nError;


	// Set up Atlantic UART Link
	printf ("Openning JTAG Atlantic Link...\n");
	link = jtagatlantic_open (0, 0x0, -1, 0);

	if (!link) {
		printf ("Unable to open JTAG Atlantic link.\n");
		return -1;
	}

	printf ("Link established.\n\n");

	if (jtagatlantic_flush(link)) {
		printf("\n\nError on JTAG Link flush\n\nExiting\n");
	        return(-1);
	}


	// Set up TCP server
	if (WSAStartup (0x101, &wsaData)) {
		printf("\n\nError starting Winsock.\nExiting\n");
		return -1;
	}

	local.sin_family = AF_INET;
	local.sin_addr.s_addr = INADDR_ANY;
	local.sin_port = htons((u_short)9900);

	server = socket (AF_INET, SOCK_STREAM, 0);

	if (server == INVALID_SOCKET) {
		printf ("\n\nError opening local socket.\nExiting\n");
		return -1;
	}

	if (bind (server, (sockaddr*)&local, sizeof(local))) {
		nError = WSAGetLastError ();

		printf ("\n\nError starting server at 127.0.0.1:9900.\nError code: %d\nExiting\n", nError);
		return -1;
	}

	if (listen (server, 10)) {
		printf ("\n\nError starting listening socket at 127.0.0.1:9900.\nExiting\n");
		return -1;
	}


	// Main loop
	client = accept (server, (struct sockaddr*)&from, &from_len);

	ioctlsocket (client, FIONBIO, &iMode);

	while (1)
	{
		char temp[64];
		int len, sent;

		// TCP->UART
		len = recv (client, temp, 63, 0);

		nError = WSAGetLastError ();

		if (nError != WSAEWOULDBLOCK && nError != 0) {
			printf ("\n\nError reading socket: %d\nExiting\n\n", nError);
			break;
		}

		if (len > 0)
		{
			temp[len] = 0;
			printf ("to fpga:\t\"%s\"\n", temp);
			jtagatlantic_write (link, temp, len);
		}

		// UART->TCP
		len = jtagatlantic_read (link, temp, 63);

		if (len > 0)
		{
			temp[len] = 0;
			printf ("from fpga:\t\"%s\"\n", temp);

			while (len > 0) {
				sent = send (client, temp, len, 0);

				if (nError != WSAEWOULDBLOCK && nError != 0) {
					printf ("\n\nError reading socket: %d\nExiting\n\n", nError);
					return -1;
				}

				if (sent > 0)
					len -= sent;

				Sleep (1);
			}
		}

		if (jtagatlantic_flush(link)) {
			printf("\n\nError on JTAG Link flush\n\nExiting\n");
			break;
		}

		Sleep (1);
	}

	jtagatlantic_close (link);

	shutdown(client, SD_SEND);
	closesocket (client);
	closesocket (server);
	WSACleanup ();

	return 0;
}

