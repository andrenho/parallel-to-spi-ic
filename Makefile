# Project name
PROJECT=parallel-to-spi

# Object files (one for each source file)
OBJECTS=main.o

# Avrdude configuration to connect on the PI. See avrdude_gpio.conf.
# Can be one of: pi_rst, pi_cs0, pi_cs1 or pi_gpio, depending on the RESET line in AVR.
AVRDUDE_CONFIG=pi_rst

# AVR fuses: external crystal (see https://www.engbedded.com/fusecalc/)
FUSES=-U lfuse:w:0xff:m -U hfuse:w:0xd8:m -U efuse:w:0xfd:m

# Microcontroller
MCU_GCC=atmega8
MCU_AVRDUDE=atmega8
MCU_LD=avr6

# Microcontroller speed, in Hz. Used by avr-libc for delays.
F_CPU=8000000UL

# Serial speed, in baud. Used by avr-libc for UART speed calculation.
BAUD=$(shell cat ../BAUD)

CFLAGS=-I. -Idev -Ifsfat -Iinterface -Iio

#
# Rules
#

AVRDUDE_FLAGS=-p ${MCU_AVRDUDE} -C +./avrdude_gpio.conf -c ${AVRDUDE_CONFIG} -V -B1
CC=avr-gcc
WARNINGS=-Wall -Wextra \
	 -Wformat=2 -Wno-unused-parameter -Wshadow \
	 -Wwrite-strings -Wstrict-prototypes -Wold-style-definition \
	 -Wredundant-decls -Wnested-externs -Wmissing-include-dirs -Wjump-misses-init -Wlogical-op
CPPFLAGS=-std=c11 ${WARNINGS} -Os -DF_CPU=${F_CPU} -DBAUD=${BAUD} -mmcu=${MCU_GCC} ${DEFINES} -ffunction-sections -fdata-sections -mcall-prologues

all: ${PROJECT}.hex

${PROJECT}.hex: ${PROJECT}.elf
	avr-objcopy -j .text -j .data -O ihex $< $@

${PROJECT}.elf: ${OBJECTS} bios.o
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
