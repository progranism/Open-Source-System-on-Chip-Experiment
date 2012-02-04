// Inspired by the DHCP implementation in lwIP, Copyright (C) Leon Woestenberg and Axon Digital Design.
//

#include <net/microudp.h>
#include <stdlib.h>


struct dhcp_msg {
	unsigned char op;
	unsigned char htype;
	unsigned char hlen;
	unsigned char hops;
	unsigned int xid;
	unsigned short secs;
	unsigned short flags;
	unsigned int ciaddr;
	unsigned int yiaddr;
	unsigned int siaddr;
	unsigned int giaddr;
	unsigned char chaddr[16];
	unsigned char sname[64];
	unsigned char file[128];
	unsigned int magic_cookie;
	unsigned char options[68];
} __attribute__((packed));

enum {
	DHCP_OFF = 0, DHCP_REQUESTING, DHCP_INIT, DHCP_REBOOTING, DHCP_REBINDING,
	DHCP_RENEWING, DHCP_SELECTING, DHCP_INFORMING, DHCP_CHECKING, DHCP_PERMANENT,
	DHCP_BOUND, DHCP_BACKING_OFF
};

#define DHCP_DISCOVER 1
#define DHCP_OFFER    2
#define DHCP_REQUEST  3
#define DHCP_DECLINE  4
#define DHCP_ACK      5
#define DHCP_NAK      6
#define DHCP_RELEASE  7
#define DHCP_INFORM   8

#define DHCP_OPTION_PAD 0
#define DHCP_OPTION_SUBNET_MASK 1 /* RFC 2132 3.3 */
#define DHCP_OPTION_ROUTER 3
#define DHCP_OPTION_DNS_SERVER 6 
#define DHCP_OPTION_HOSTNAME 12
#define DHCP_OPTION_IP_TTL 23
#define DHCP_OPTION_MTU 26
#define DHCP_OPTION_BROADCAST 28
#define DHCP_OPTION_TCP_TTL 37
#define DHCP_OPTION_END 255

#define DHCP_OPTION_SERVER_ID 54 /* RFC 2132 9.7, server IP address */
#define DHCP_OPTION_PARAMETER_REQUEST_LIST 55 /* RFC 2132 9.8, requested option types */

#define DHCP_OPTION_MESSAGE_TYPE 53 /* RFC 2132 9.6, important for DHCP */
#define DHCP_OPTION_MESSAGE_TYPE_LEN 1

#define DHCP_OPTION_REQUESTED_IP 50 /* RFC 2132 9.1, requested IP address */


static int dhcp_state = 0;
static unsigned int dhcp_xid;

static unsigned int my_subnet_mask = 0;
static unsigned int my_router = 0;
static unsigned int my_dns = 0;
static unsigned int my_dhcp_server = 0;


static void dhcp_option (struct dhcp_msg *dhcp, unsigned int *options_len, unsigned char option_type, unsigned char option_len)
{
	dhcp->options[(*options_len)++] = option_type;
	dhcp->options[(*options_len)++] = option_len;
}

static void dhcp_option_byte (struct dhcp_msg *dhcp, unsigned int *options_len, unsigned char value)
{
	dhcp->options[(*options_len)++] = value;
}

static void dhcp_option_long (struct dhcp_msg *dhcp, unsigned int *options_len, unsigned int value)
{
	dhcp->options[(*options_len)++] = value >> 24;
	dhcp->options[(*options_len)++] = value >> 16;
	dhcp->options[(*options_len)++] = value >> 8;
	dhcp->options[(*options_len)++] = value;
}

static unsigned int dhcp_option_read_long (unsigned char *buf)
{
	return (buf[0] << 24) | (buf[1] << 16) | (buf[2] << 8) | buf[3];
}

static void dhcp_option_trailer(struct dhcp_msg *dhcp, unsigned int *options_len)
{
	dhcp->options[(*options_len)++] = DHCP_OPTION_END;

	while (*options_len < 68)
		dhcp->options[(*options_len)++] = 0;
}

static void dhcp_build_msg (struct dhcp_msg *dhcp, unsigned int *options_len, unsigned char message_type)
{
	int i;
	unsigned char *mac = microudp_get_mac ();

	dhcp->op = 1;
	dhcp->htype = 1;
	dhcp->hlen = 6;
	dhcp->hops = 0;
	dhcp->xid = dhcp_xid;
	dhcp->secs = 0;
	dhcp->flags = 1 << 15;	// Broadcast results back to us, instead of unicast
	dhcp->ciaddr = 0;
	dhcp->yiaddr = 0;
	dhcp->siaddr = my_dhcp_server;
	dhcp->giaddr = 0;
	for (i = 0; i < 16; ++i) {
		if (i < 6)
			dhcp->chaddr[i] = mac[i];
		else
			dhcp->chaddr[i] = 0;
	}
	for (i = 0; i < 64; ++i)
		dhcp->sname[i] = 0;
	for (i = 0; i < 128; ++i)
		dhcp->file[i] = 0;
	dhcp->magic_cookie = 0x63825363;
	dhcp_option (dhcp, options_len, DHCP_OPTION_MESSAGE_TYPE, DHCP_OPTION_MESSAGE_TYPE_LEN);
	dhcp_option_byte (dhcp, options_len, message_type);
}

static void dhcp_discover (void)
{
	unsigned int options_len = 0;

	dhcp_state = DHCP_SELECTING;

	struct dhcp_msg *dhcp = microudp_get_tx_buffer ();

	dhcp_build_msg (dhcp, &options_len, DHCP_DISCOVER);

	dhcp_option(dhcp, &options_len, DHCP_OPTION_PARAMETER_REQUEST_LIST, 4);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_SUBNET_MASK);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_ROUTER);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_BROADCAST);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_DNS_SERVER);
	
	dhcp_option_trailer (dhcp, &options_len);

	microudp_arp_resolve (0xFFFFFFFF);
	microudp_send (68, 67, sizeof(struct dhcp_msg));
}

static void dhcp_request (unsigned int offered_ip)
{
	unsigned int options_len = 0;
	struct dhcp_msg *dhcp = microudp_get_tx_buffer ();

	dhcp_state = DHCP_REQUESTING;

	dhcp_build_msg (dhcp, &options_len, DHCP_REQUEST);

	dhcp_option(dhcp, &options_len, DHCP_OPTION_REQUESTED_IP, 4);
	dhcp_option_long(dhcp, &options_len, offered_ip);

	dhcp_option(dhcp, &options_len, DHCP_OPTION_SERVER_ID, 4);
	dhcp_option_long(dhcp, &options_len, my_dhcp_server);

	dhcp_option(dhcp, &options_len, DHCP_OPTION_PARAMETER_REQUEST_LIST, 4);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_SUBNET_MASK);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_ROUTER);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_BROADCAST);
	dhcp_option_byte(dhcp, &options_len, DHCP_OPTION_DNS_SERVER);
	
	dhcp_option_trailer (dhcp, &options_len);

	microudp_arp_resolve (0xFFFFFFFF);
	microudp_send (68, 67, sizeof(struct dhcp_msg));
}

static void dhcp_parse_options (struct dhcp_msg *dhcp)
{
	// Parse options
	unsigned char *options = dhcp->options;
	unsigned int parsed = 0;

	while (parsed < 68)
	{
		if (options[0] == 0xFF)
			break;

		if (options[0] == 54)
			my_dhcp_server = dhcp_option_read_long(options + 2);
		else if (options[0] == 1)
			my_subnet_mask = dhcp_option_read_long(options + 2);
		else if (options[0] == 3)
			my_router = dhcp_option_read_long(options + 2);
		else if (options[0] == 6)
			my_dns = dhcp_option_read_long(options + 2);

		if (options[1] == 0 || options[1] > 68) break;

		parsed += options[1];
		options += options[1] + 2;
	}
}

static void dhcp_handle_ack (struct dhcp_msg *dhcp)
{
	my_dhcp_server = dhcp->siaddr;

	dhcp_parse_options (dhcp);

	microudp_set_ip (dhcp->yiaddr);

	// TODO: Configure lease timers
	
	dhcp_state = DHCP_BOUND;
}

static void dhcp_handle_offer (struct dhcp_msg *dhcp)
{
	unsigned int offered_ip = dhcp->yiaddr;
	my_dhcp_server = dhcp->siaddr;

	dhcp_parse_options (dhcp);

	dhcp_request (offered_ip);
}

static void dhcp_callback (unsigned int src_ip, unsigned short src_port, unsigned short dst_port, void *data, unsigned int length)
{
	struct dhcp_msg *dhcp = data;

	if (length < sizeof(struct dhcp_msg))
		return;

	if (dhcp->magic_cookie != 0x63825363 || dhcp->op != 2 || dhcp->htype != 1) return;
	if (dhcp->hlen != 6 || dhcp->xid != dhcp_xid) return;
	if (dhcp->options[0] != DHCP_OPTION_MESSAGE_TYPE || dhcp->options[1] != 1) return;

	if (dhcp->options[2] == DHCP_OFFER && dhcp_state == DHCP_SELECTING) {
		dhcp_handle_offer (dhcp);
	}
	else if (dhcp->options[2] == DHCP_ACK && dhcp_state == DHCP_REQUESTING)
		dhcp_handle_ack (dhcp);
}

void dhcp_boot (unsigned char *my_mac)
{
	dhcp_xid = rand ();
	microudp_set_callback (dhcp_callback);

	dhcp_discover ();

	while (dhcp_state != DHCP_BOUND)
	{
		microudp_service ();
	}
}

