#include <avr/io.h>
#include <stdint.h>

static const struct {
	volatile uint8_t *port;
	volatile uint8_t *ddr;
	uint8_t mask;
} port_map[] = {
#define P(port, bit) { &PORT##port, &DDR##port, 1 << bit }
	/* port numbers 0-7: */
	P(D, 0), P(D, 1), P(D, 2), P(D, 3), P(D, 4), P(D, 5), P(D, 6), P(D, 7),
	/* port numbers 8-13: */
	P(B, 0), P(B, 1), P(B, 2), P(B, 3), P(B, 4), P(B, 5),
	/* port numbers 14-19: */
	P(C, 0), P(C, 1), P(C, 2), P(C, 3), P(C, 4), P(C, 5),
#undef P
};
#define NUM_PORTS (sizeof(port_map) / sizeof(*port_map))

// Calculate UBRRL_VALUE and UBRRH_VALUE
#define BAUD 9600
#include <util/setbaud.h>

int main(void)
{
	// Initialize outputs to output
	for (uint8_t i = 0; i < NUM_PORTS; ++i) {
		*port_map[i].ddr |= port_map[i].mask;
	}
	// Reset receiver pin to input (it was set to output by the above loop)
	DDRD &= ~_BV(PD0);
	// Set baud rate
	UBRR0L = UBRRL_VALUE;
	UBRR0H = UBRRH_VALUE;
	// Enable receiver
	UCSR0B = _BV(RXEN0);
	// Set frame format to 8 data bits and 1 stop bit
	UCSR0C = _BV(UCSZ01) | _BV(UCSZ00);
	// Main loop
	for (;;) {
		// Test if an input byte is available
		if (UCSR0A & _BV(RXC0)) {
			// Set cmd to the input byte
			uint8_t cmd = UDR0;
			// Set p to the requested port
			uint8_t p = cmd & 127;
			// Test if the requested port is valid
			if (p < NUM_PORTS) {
				if (cmd & 128) {
					// The request was to turn it on
					*port_map[p].port |= port_map[p].mask;
				} else {
					// The request was to turn it off
					*port_map[p].port &= ~port_map[p].mask;
				}
			}
		}
	}
}

