# GPSM (General Purpose Signal Multiplexer)

This is a program to be run on an AVR ATmega328p such as an Arduino in order to
multiplex port output over a UART connection. It should be pretty easily to port
to other AVR devices.

## Installation

You will need avrdude to upload the program to the AVR. Install it like so:

```
# Linux:
sudo apt install avrdude

# Mac:
brew install avrdude
```

After that, just run this:

```
make upload port=<device>
```

where `<device>` is the name of the serial connection to the USB. The default is
`/dev/ttyUSB0`.

## Operation

Plug your AVR into your computer's USB port after doing what you will with the
pins, e.g. attaching LEDS on a breadboard. Then send data down the USB using the
protocol described below.

### Protocol

In the protocol, each message in one byte. The most significant bit can be zero
or one. Zero indicates the port should turn off. One indicates it should turn
on. The lower five bits specify which port to switch (so there can be at most 32
ports.) The implementation decides which number corresponds to which port. My
implementation numbers the ports the same as their labels on my Sparkfun board.
To change the numbering, see **Adapting**.

### Shell interface

Following is a method to communicate with the AVR using the Unix shell. I
haven't gotten this working on Mac; the Arduino I'm using doesn't seem to pick
up all the bytes. I don't know the reason.

```
set_pin() { printf \\$(printf %o $(($1+$2*128))); }
mkfifo usb
tail -f usb > /dev/ttyUSB0  # Or whatever the USB device is
set_pin >usb 3 1  # Turns on pin 3
set_pin >usb 3 0  # Turns off pin 3
```

## Compilation

You do not need to compile if all you are doing is uploading the program. If you
need to make changes, you'll have to install some stuff:

```
# Linux:
sudo apt install gcc-avr binutils-avr avr-libc avrdude

# Mac:
brew tap osx-cross/avr
brew install avr-libc
```

## Adapting

The table mapping numbers to actual pins is at the bottom of `gpsm.S`. The
number is indicated by an entry's place in the table. The information specified
is the port register (D, B, etc.) and which bit of the register to use. More
information is available in `gpsm.S`.
