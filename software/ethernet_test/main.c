#include <hw/gpio.h>
#include <hw/uart.h>

static void ethreset_delay()
{
	volatile int count = 0;

	// TODO: Use a real timer
	for (; count <= 2000000; ++count);
}

static void ethreset()
{
	CSR_MINIMAC_SETUP = MINIMAC_SETUP_PHYRST;
	ethreset_delay();
	CSR_MINIMAC_SETUP = 0;
	ethreset_delay();
}

int main(int i, char **c)
{
	int count = 0;

	ethreset();
	print_mac();

	while (1)
	{
		if (count == 1000000) {
			CSR_GPIO = (CSR_GPIO&1) ? 0xF0F0F0F0 : 0x0F0F0F0F;
			count = 0;
		}

		count++;

		if (CSR_UART_RX != 0 && CSR_UART_TX == 0) {
			CSR_UART_TX = CSR_UART_RX & 0xFF;
			CSR_UART_RX = 0;
		}
	}

	return 0;
}

void isr (void)
{
}

