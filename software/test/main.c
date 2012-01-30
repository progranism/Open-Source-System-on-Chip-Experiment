#include <hw/gpio.h>
#include <hw/uart.h>


int main(int i, char **c)
{
	int count = 0;

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

