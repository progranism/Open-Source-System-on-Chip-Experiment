void _start()
{
	unsigned int *x = 0x00000040;
	unsigned int *gpio = 0x60001004;

	while (1)
	{
		*x = *x + 1;
		*gpio = *x;
	}
}
