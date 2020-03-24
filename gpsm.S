#include <avr/io.h>

#define BAUD 9600
#include <util/setbaud.h>
.equ _UBRRL_VALUE, UBRRL_VALUE
.equ _UBRRH_VALUE, UBRRH_VALUE

.section .text

init:
	clr YH
	clr ZH
	ldi ZL, port_map
1:	lpm r17, Z+
	lpm r17, Z+
	lpm YL, Z+
	tst YL
	breq .Linit_uart
	ld r18, Y
	or r18, r17
	st Y, r18
	rjmp 1b

.Linit_uart:
	ldi r17, _UBRRH_VALUE
	sts UBRR0H, r17
	ldi r17, _UBRRL_VALUE
	sts UBRR0L, r17
	ldi r17, _BV(RXEN0)
	sts UCSR0B, r17
	ldi r17, _BV(UCSZ01) | _BV(UCSZ00)
	sts UCSR0C, r17

.Lpoll:
	lds r17, UCSR0A
	andi r17, _BV(RXC0)
	breq .Lpoll
	lds r17, UDR0
	mov r18, r17
	andi r17, 0b01111111
	clr ZH
	ldi ZL, port_map
	add ZL, r17
	brcc 1f
	inc ZH
1:	add ZL, r17
	brcc 1f
	inc ZH
1:	add ZL, r17
	brcc 1f
	inc ZH
1:	lpm YL, Z+
	lpm r20, Z
	ld r21, Y
	andi r18, 0b10000000
	breq 1f
	or r21, r20
	rjmp 2f
1:	neg r20
	dec r20
	and r21, r20
2:	st Y, r21
	rjmp .Lpoll

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
