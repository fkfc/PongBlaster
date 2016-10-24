;
;
;	joystick.s	- Leitura dos joysticks
;
;	Compilar no SDCC para MSX
;
;       Reference: http://fms.komkon.org/MSX/Docs/Portar.txt
;       Bit #:  76  5    4   3210
;               ||  |    |   ||||
;       Name:   10 TRG2 TRG1 RLDU
	.area _CODE
	

_joystick_1_read::
	ld	a,#0x0F
	out	(#0xA0),a
	in	a,(#0xA2)
	and	#0xAF
	or	#0x03
	out	(#0xA1),a
	ld	a,#0x0E
	out	(#0xA0),a
	in	a,(#0xA2)
	xor	#0xFF
	ld	l,a
	ld	h,#0
	ret  

	
_joystick_2_read::
	ld	a,#0x0F
	out	(#0xA0),a
	in	a,(#0xA2)
	and	#0xDF
	or	#0x4C
	out	(#0xA1),a
	ld	a,#0x0E
	out	(#0xA0),a
	in	a,(#0xA2)
	xor	#0xFF
	ld	l,a
	ld	h,#0
	ret  