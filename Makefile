flags = -mmcu=$(mcu) -DF_CPU=$(f-cpu) $(CFLAGS)
mcu = atmega328p
partno = m328p
f-cpu = 16000000
port = /dev/ttyUSB0
programmer = arduino

gpsm.hex: gpsm.S
	avr-gcc $(flags) -c -o gpsm.o $<
	avr-ld -o $@ gpsm.o
	avr-objcopy -O ihex $@
	chmod -x $@

.PHONY: upload
upload: gpsm.hex
	avrdude -c$(programmer) -p$(partno) -P$(port) -Uflash:w:$<:i

.PHONY: clean
clean:
	rm -f gpsm.o
