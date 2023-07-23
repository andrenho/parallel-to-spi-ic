# Parallel to SPI converter IC using ATMEGA microcontroller.

Embedding this code in a ATMEGA8/48/88/168/328 will allow the microcontroller to act as 8-bit parallel to SPI master converter.

The pinout of the ATMEGA will be as follows:

```
       .------.
RESET -|1   28|- D5
 ~CS1 -|2   27|- D4
 ~CS2 -|3   26|- D3
  ~RD -|4   25|- D2
  ~WR -|5   24|- D1
   RS -|6   23|- D0
  VCC -|7   22|- 
  GND -|8   21|- 
XTAL1 -|9   20|- 
XTAL2 -|10  19|- SCK
      -|11  18|- MISO
   D6 -|12  17|- MOSI
   D7 -|13  16|- ~CS0
 ~IRQ -|14  15|- ~IN_USE
       `------´

```
