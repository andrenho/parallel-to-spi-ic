# Parallel to SPI converter IC using ATMEGA microcontroller.

Embedding this code in a ATMEGA8/48/88/168/328 will allow the microcontroller to act as 8-bit parallel to SPI master converter.

The pinout of the ATMEGA will be as follows:

```
        .------.
~RESET -|1   28|- D5
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

The pins are used as follows:

* **~WR** (input): when pulled down, will read the values from the **D[0..7]** pins and write them either to the config register, or to the SPI bus, depending on the state of the **~RS** pin. If data is sent over the SPI bus, the exchanged bits received on the SPI are placed on the data register. Once the whole process is finished, a low pulse will be sent to **~IRQ**.
* **~RD** (input): when pulled down, will write the data register the the **D[0..7]** pins. Once the data is available, a low pulse will be sent to **~IRQ**.
* **RS** (input): selected either the config register (high) or the data register (low).
* **D[0..7]** (input/output): used to either read or write to the data register.
* **MOSI** (output), **MISO** (input), **SCK** (output): connect these to the SPI bus.
* **CS0**, **CS1**, **CS2** (output): depending on the config register, will activate one of these SPI slaves.
* **~IRQ** (output): will send a low pulse every time a operation (read or write) is completed.
* **~IN_USE** (output): indicated that a communication is currently happening. Can be used to light up a LED.
* **XTAL1**, **XTAL2** (input): can be used to either connect a crystal, or a clock input (on port XTAL1), or not used at all - in this case a internal oscillator is used. This can be configured by setting fuse bits in the microcontroller. For more information, read the microcontroller datasheet.
* **~RESET** (input): set to high for normal operation, and to low to reset the device.
