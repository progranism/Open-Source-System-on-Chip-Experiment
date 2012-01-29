#include <hw/gpio.h>

int main(int i, char **c)
{
	int count = 0;

	while (1)
	{
		CSR_GPIO = count++;
	}

	return 0;
}

void isr (void)
{
}

