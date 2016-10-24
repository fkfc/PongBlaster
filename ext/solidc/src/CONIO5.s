;---
;
;	CONIO.H
;	Low level console functions
;
;	(c) 1997, SOLID MSX C
;
;
;
;	SDCC port 2015
;	Extended CONIO, uses DOS functions CALL 5
;
;---

	.area _CODE

;--- proc   GETSCON

_getscon::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix)
	pop ix

	ld  (#lb_18),hl
	ld  hl,#0xFEFA	; buffer 0x106 in stack
	add hl,sp
	ld  sp,hl
	ld  hl,(#lb_18)
	push hl
	ld  (#lb_23),hl
	ld  a,e
	dec a
	dec a
	ld  hl,#0x2
	add hl,sp
	ld  (hl),a
	ld  hl,#0x2
	add hl,sp
	ex  de,hl
	ld  c,#10
	call    #5
	ld  e,#10
	ld  c,#2
	call    #5
	ld  hl,#0x4
	add hl,sp
	ld  a,(hl)
	pop hl
	cp  #0xA
	jr  nz,lb_5
	xor a
	ld (de),a
	ld  b,#0
	jr  lb_6

lb_5:
	push    hl
	ld  hl,#0x3
	add hl,sp
	ld  c,(hl)
	ld b,#0
	ld  hl,#0x4
	add hl,sp
	ex  de,hl
	pop hl
lb_8:
	dec c
	ld  a,c
	inc a
	jr  z,lb_7
	ld  a,(de)
	inc de
	inc b
	ld  (hl),a
	inc hl
	jr  lb_8
lb_7:
	xor a
	ld  (hl),a
	ld  hl,(#lb_23)
lb_6:
	ex  de,hl
	ld  hl,#0x106	;0x10000-0xFEFA
	add hl,sp
	ld  sp,hl
	ex  de,hl
	ld l,b
	ld h,#0
	ret

	.area _DATA
	
lb_18:  .db #0,#0
lb_23:  .db #0,#0

	.area _CODE
	
;--- end of proc 

;--- proc   GETCON

_getcon::
	ld  c,#1
	call    #5
	cp  #13
	jr nz, lb_gc1
	ld  a,#10
	push    af
	ld  c,#2
	ld  e,a
	call    #5
	pop af
lb_gc1:
	ld h,#0
	ld l,a
	ret

;--- end of proc 

_putchar::
	ld      hl,#2
	add     hl,sp
	ld	e,(hl)

	ld	c,#2
	call	5
	ret

_getchar::
	ld	c,#8
	call	5
	ld l,a
	ld h,#0
	ret 