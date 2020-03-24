elf = gpsm.elf
flags = -mmcu=$(mcu) -O3 -Wall -Wextra -DF_CPU=$(f-cpu) $(CFLAGS)
mcu = atmega328p
partno = m328p
f-cpu = 16000000
port = /dev/ttyUSB0
programmer = arduino

$(elf): gpsm.S
	avr-gcc $(flags) -c -o gpsm.o $<
	avr-ld -o $@ gpsm.o

.PHONY: upload
upload: $(elf)
	sudo avrdude -c$(programmer) -p$(partno) -P$(port) -Uflash:w:$(elf):e

.PHONY: view_asm
view_asm: $(elf)
	@avr-objdump -d $(elf) | less

.PHONY: clean
clean:
	$(RM) $(elf)
