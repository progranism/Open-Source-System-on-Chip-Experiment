int sld_node_lock (int a, int b);
int sld_node_access_ir (int a, int b, int c, int d);
int sld_node_access_dr (int a, int len, unsigned int *data_to_write, unsigned char *data_read, int e);
int sld_node_unlock (int a);

int sld_hub_open (const char *hardware_name, const char *device_name, unsigned int *a);
int sld_hub_close (unsigned int *a);

int main (int argc, char *argv[])
{
	unsigned int x = 0;
	unsigned int z = 0;

	printf ("%d\n", sld_hub_open ("USB-Blaster [USB-0]", "@1: EP3C120/EP4CE115 (0x020F70DD)", &z));
	printf ("%.08X\n", z);
	printf ("%d\n", sld_hub_close (&z));

	// Put device into reset
	printf ("%d\n", sld_node_lock (0, 7530));
	printf ("%d\n", sld_node_access_ir (0, 8, 0, 0));
	printf ("%d\n", sld_node_access_dr (0, 1, &x, 0, 0));
	printf ("%d\n", sld_node_unlock (0));

	return 0;
}

