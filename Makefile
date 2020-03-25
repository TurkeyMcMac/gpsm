flags = -mmcu=$(mcu) -DF_CPU=$(f-cpu) $(CFLAGS)
mcu = atmega328p
partno = m328p
f-cpu = 16000000
port = /dev/ttyUSB0
programmer = arduino

gpsm.hex: gpsm.o
	avr-ld -o $@ $<
	avr-objcopy -O ihex $@
	chmod -x $@

gpsm.o: gpsm.S
	avr-gcc $(flags) -c -o $@ $<

.PHONY: upload
upload: gpsm.hex
	avrdude -c$(programmer) -p$(partno) -P$(port) -Uflash:w:$<:i

.PHONY: view_asm
view_asm: gpsm.o
	avr-objdump -d $< | less

.PHONY: clean
clean:
	$(RM) gpsm.o
