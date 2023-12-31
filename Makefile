# Project name
PROJECT=parallel-to-spi

# Object files (one for each source file)
OBJECTS=parallel-to-spi.o

# Avrdude configuration to connect on the PI. See avrdude_gpio.conf.
# Can be one of: pi_rst, pi_cs0, pi_cs1 or pi_gpio, depending on the RESET line in AVR.
AVRDUDE_CONFIG=pi_rst

# AVR fuses: external clock (see https://www.engbedded.com/fusecalc/)
FUSES=-U lfuse:w:0xe0:m -U hfuse:w:0xd9:m

# Microcontroller
MCU_GCC=atmega8
MCU_AVRDUDE=atmega8
MCU_LD=avr6

# Serial speed, in baud. Used by avr-libc for UART speed calculation.
BAUD=$(shell cat ../BAUD)

CFLAGS=

#
# Rules
#

AVRDUDE_FLAGS=-p ${MCU_AVRDUDE} -C +./avrdude_gpio.conf -c ${AVRDUDE_CONFIG} -V -B1
CC=avr-gcc
WARNINGS=-Wall -Wextra \
	 -Wformat=2 -Wno-unused-parameter -Wshadow \
	 -Wwrite-strings \
	 -Wredundant-decls -Wnested-externs -Wmissing-include-dirs -Wjump-misses-init -Wlogical-op
CPPFLAGS=-std=c11 ${WARNINGS} -Os -DBAUD=${BAUD} -mmcu=${MCU_GCC} ${DEFINES} -ffunction-sections -fdata-sections -mcall-prologues

all: ${PROJECT}.hex

${PROJECT}.hex: ${PROJECT}.elf
	avr-objcopy -j .text -j .data -O ihex $< $@

${PROJECT}.elf: ${OBJECTS}
	$(CC) -mmcu=${MCU_GCC} ${CFLAGS} ${CPPFLAGS} -o $@ $^ -Wl,--gc-sections
	avr-size -C --mcu=${MCU_GCC} ${PROJECT}.elf	

test-connection:
	sudo avrdude ${AVRDUDE_FLAGS}

upload: ${PROJECT}.hex
	sudo avrdude ${AVRDUDE_FLAGS} -U flash:w:$<:i

fuse:
	sudo avrdude ${AVRDUDE_FLAGS} ${FUSES}

size: ${PROJECT}.elf
	avr-size -C --mcu=${MCU_GCC} ${PROJECT}.elf	

talk:
	@echo "Press Ctrl+A and then Shift+K to exit."
	@sleep 1
	sudo screen /dev/serial0 ${BAUD}

clean:
	rm -f ${OBJECTS} ${PROJECT}.elf ${PROJECT}.hex

# vim: set ts=8 sts=8 sw=8 noexpandtab:
