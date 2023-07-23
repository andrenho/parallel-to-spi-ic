#include <avr/io.h>
#include <avr/sfr_defs.h>
#include <stdbool.h>
#include <stdint.h>

// pinout

#define IRQ    PB0
#define IN_USE PB1
#define CS1    PB2
#define MOSI   PB3
#define MISO   PB4
#define SCK    PB5

#define D0     PC0
#define D1     PC1
#define D2     PC2
#define D3     PC3
#define D4     PC4
#define D5     PC5

#define CS2    PD0
#define CS3    PD1
#define RD     PD2
#define WR     PD3
#define RS     PD4    // 0 - data register, 1 - config register
#define D6     PD6
#define D7     PD7

#define CONFIG_CS    0b00000011
#define CONFIG_END   0b00000100
#define CONFIG_CPOL  0b00001000
#define CONFIG_CPHA  0b00010000
#define CONFIG_SPD0  0b00100000
#define CONFIG_SPD1  0b01000000
#define CONFIG_SPD2  0b10000000

// registers

uint8_t data = 0xff;
uint8_t config = 0x0;

static void irq_pulse()
{
	DDRB &= ~_BV(IRQ);
	DDRB |= _BV(IRQ);
}

static void read(bool rs)
{
	// figure out registers
	uint8_t output = rs ? config : data;

	// write to port
	DDRC |= _BV(D0) | _BV(D1) | _BV(D2) | _BV(D3) | _BV(D4) | _BV(D5);
	DDRD |= _BV(D6) | _BV(D7);
	PORTC |= output & 0b00111111;
	PORTD |= output & 0b11000000;

	// pulse
	irq_pulse();

	// wait until read is over
	loop_until_bit_is_set(PORTD, RD);

	// restore data lines to high impedance
	DDRC = 0x0;
	DDRD &= ~_BV(D6) & ~_BV(D7);
}

static void write_data()
{
	uint8_t value = (PINC & 0b111111) | (PIND & 0b11000000);

	// set CS ports
	uint8_t cs = value & CONFIG_CS;
	PORTB |= _BV(CS1);
	PORTD |= _BV(CS2) | _BV(CS3);
	if (cs == 0x1)
		PORTB &= ~_BV(CS1);
	else if (cs == 0x2)
		PORTD &= ~_BV(CS2);
	else if (cs == 0x3)
		PORTD &= ~_BV(CS3);

	// set IN_USE pin
	if (cs == 0)
		PORTB |= _BV(IN_USE);
	else
		PORTB &= ~_BV(IN_USE);

	// configure SPI
	uint8_t spcr = _BV(SPE) | _BV(MSTR);
	if (value & CONFIG_END)
		spcr |= _BV(DORD);
	if (value & CONFIG_CPOL)
		spcr |= _BV(CPOL);
	if (value & CONFIG_CPHA)
		spcr |= _BV(CPHA);
	if (value & CONFIG_SPD0)
		spcr |= _BV(SPR0);
	if (value & CONFIG_SPD1)
		spcr |= _BV(SPR1);
	SPCR = spcr;

	if ((value & CONFIG_SPD2) != (config & CONFIG_SPD2)) {
		if (value & CONFIG_SPD2)
			SPSR |= _BV(SPI2X);
		else
			SPSR &= ~_BV(SPI2X);
	}

	config = value;

	irq_pulse();
}

static void write_config()
{
	// send byte
	SPDR = (PINC & 0b111111) | (PIND & 0b11000000);
	
	// wait until completed
	loop_until_bit_is_set(SPSR, SPIF);

	// set data register with the result
	data = SPDR;

	irq_pulse();
}

int main()
{
	// setup ports
	DDRB = 0b101111;   // outputs: IRQ, IN_USE, CS1
	DDRC = 0x0;
	DDRD = 0b11;    // outputs: CS2, CS3

	// initialize normally high pins
	PORTB = _BV(IRQ) | _BV(IN_USE) | _BV(CS1);
	PORTD = _BV(CS2) | _BV(CS3);

	// initialize SPI as master
	SPCR |= (1 << SPE) | (1 << MSTR);

	// main loop
	while (1) {
		uint8_t in = PIND;

		if ((in & _BV(RD)) == 0) {
			read(in & _BV(RS));
		} else if ((in & _BV(WR)) == 0) {
			if (in & _BV(RS))
				write_data();
			else
				write_config();
		}
	}
}
