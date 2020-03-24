#include <avr/io.h>

; Each port number is an index into an array of structures in program memory.
; Each structure is three bytes: PORT address, mask, DDR address. The PORT is
; PORTD, PORTB, etc. The mask is set to the bit for the particular port. The
; mask is zero if the port is reserved. DDR points to DDRD, DDRB, etc.

#define BAUD 9600
#include <util/setbaud.h>
; The expressions cannot be evaluated inline, so they are evaluated here:
.equ _UBRRL_VALUE, UBRRL_VALUE
.equ _UBRRH_VALUE, UBRRH_VALUE

.section .text

; Set available ports to outputs:
init:
	; Clear Y's high bytes for the duration of the program:
	clr YH
	; Set Z to the address of port_map:
	clr ZH
	ldi ZL, port_map
	; Increment Z to point to the mask field:
1:	lpm r17, Z+
	; Load the mask field into r17:
	lpm r17, Z+
	; Load the address of the DDR into Y:
	lpm YL, Z+
	; Check if the address is zero:
	tst YL
	; Stop if the address is zero; thats the end of the list:
	breq 2f
	; Switch the port to output by ORing the mask into the DDR:
	ld r18, Y
	or r18, r17
	st Y, r18
	; Repeat until a DDR address of zero is found:
	rjmp 1b
	; Clear Z's high byte for the remainder of the program:
2:	clr ZH
	; Initialize the UART:

; Set up the UART to receive bytes:
.Linit_uart:
	; Set the baud rate:
	ldi r17, _UBRRH_VALUE
	sts UBRR0H, r17
	ldi r17, _UBRRL_VALUE
	sts UBRR0L, r17
	; Set the UART to receive and not transmit:
	ldi r17, _BV(RXEN0)
	sts UCSR0B, r17
	; Set the format to eight data bits, one stop bit:
	ldi r17, _BV(UCSZ01) | _BV(UCSZ00)
	sts UCSR0C, r17
	; Start polling:

; Process the next byte if it is present:
.Lpoll:
	; Check if the flag indicating a byte's available is set:
	lds r17, UCSR0A
	andi r17, _BV(RXC0)
	; If it isn't set, poll again:
	breq .Lpoll
	; Load the available byte into r17:
	lds r17, UDR0
	; Copy the byte into r18 to later test if the request is for on or off:
	mov r18, r17
	; Chop r17 down to only the port number:
	andi r17, 0b00011111
	; Set Z to the address of port_map:
	ldi ZL, port_map
	; Ignoring overflow, offset Z by 3*r17, the offset of the relevant data:
	add ZL, r17
	add ZL, r17
	add ZL, r17
	; Set Y to the port register address and increment Z:
	lpm YL, Z+
	; Set r20 to the port bit mask:
	lpm r20, Z
	; Set r21 to the current value of the port register:
	ld r21, Y
	; Check whether the request was to turn the port on or off:
	andi r18, 0b10000000
	breq 1f
	; If the request was to switch it on, do so:
	or r21, r20
	rjmp 2f
	; If the request was to switch it off, do so (neg + dec = invert bits):
1:	neg r20
	dec r20
	and r21, r20
	; Store the new value back in the port register:
2:	st Y, r21
	; Poll again:
	rjmp .Lpoll

; The mapping from given port numbers to actual port bits. P(port, bit)
; indicates that bit in the given port register is reserved and cannot be
; changed. P(port, bit) indicates that the bit is up for changing.
port_map:
#define P(port, bit) PORT##port, 1 << bit, DDR##port
#define R(port, bit) PORT##port, 0, DDR##port
.dc.b\
	/* port numbers 0-7: */\
	R(D, 0), R(D, 1), P(D, 2), P(D, 3), P(D, 4), P(D, 5), P(D, 6), P(D, 7),\
	/* port numbers 8-13: */\
	P(B, 0), P(B, 1), P(B, 2), P(B, 3), P(B, 4), P(B, 5),\
	/* terminating sequence: */ 0,0,0, /* padding to even size: */ 0
#undef R
#undef P
