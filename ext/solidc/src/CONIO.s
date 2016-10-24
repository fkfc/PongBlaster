;---
;
;	CONIO.H
;	Low level console functions
;
;	(c) 1997, SOLID MSX C
;
;
;	SDCC port 2015
;	Uses BIOS only. Very basis, small code.
;
;--

	.area _CODE


;--- proc   PUTCH
;
;   void putch(char c)
;

_putch::

	ld  hl,#2
	add hl,sp
	ld a,(hl)

_iputch:

	cp  #10
	jr   nz,lb_ptch1


	ld  a,#13
	call	lb_ptch1

	ld  a,#10

lb_ptch1:

;
; BIOS call (not DOS)
;	
;	CALLF (RST 30h)
;	DB Destination slot.
;       ExxxSSPP
;       |     || Primary  slotnumber  (00-11)
;       |     - Secundary slotnumber (00-11)
;       +----------- Expanded slot (0 = no, 1 = yes (0x80))
;
;	DW  Destination address.  0x00A2 = CHPUT
;
	push ix
	.db #0xF7,#0x80,#0xA2,#0
	pop ix
	
	ret

;--- end of proc 


;--- proc   GETCH
;
;   char    getch()
;
_getch::
	
;	CALLF (RST 30h)
;	DB Destination slot. 
;	DW  Destination address.  0x009F = CHGET
;	One character input (waiting)

	push ix
	.db #0xF7,#0x80,#0x9F,#0
	pop ix
	
	ld l,a
	ld h,#0

	ret

;--- end of proc 


;--- proc   GETCHE
;
;   char    getche()
;
_getche::
    
	call    _getch
	jr  _iputch

;--- end of proc 


;--- proc   CPUTS
;
;   void    cputs(char *str)
;


_cputs::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
_icputs:

	ld  a,(hl)
	or  a
	ret z
	call    _iputch
	inc hl
	jr  _icputs

;--- end of proc 


;--- proc   CLRSCR
;
;   void clrscr()
;
_clrscr::
    
	ld  a,#12
	jr  _iputch

;--- end of proc 


;--- proc   GOHOME
;
;   void gohome()
;
_gohome::
	ld  a,#11
	jr  _iputch

;--- end of proc 


;--- proc   GOTOXY
;
;   void gotoxy(int x, int y)
;

_gotoxy::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix) 
	ld d,7(ix) 
	pop ix
_igotoxy:
    
	push    hl
	push    de
	ld  a,#27
	call    _iputch
	ld  a,#'Y'
	call    _iputch
	pop de
	ld  a,#' '
	add a,e
	call    _iputch
	pop de
	ld  a,#' '
	add a,e
	jr  _iputch

;--- end of proc 


;--- proc   KBHIT
;
;   char    kbhit()
;
_kbhit::
		;CALLF CHSNS
	push ix
	.db #0xF7,#0x80,#0x9C,#0
	pop ix
	
	or a
	jr z, lb_kb0
	ld a, #1
lb_kb0:
	ld l, a
	ld h, #0
	ret

;--- end of proc 
    
;--- proc   PUTDEC
;
;   void   putdec(int num)
;

_putdec::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)  
	pop ix
_iputdec:
    
	bit #7,h
	jr  z,lb_1
	call    lb_neghl
	ld  a,#'-'
	call    _iputch
lb_1:
	ld  de,#0
	ld  c,e
	ld  b,#16
lb_2:
	add hl,hl
	ld  a,e
	adc a,a
	daa
	ld  e,a
	ld  a,d
	adc a,a
	daa
	ld  d,a
	rl  c
	djnz    lb_2
	ld  hl, #lb_mystr+2
	call    lb_fhexw
	ld  (hl),#0
	ld  hl, #lb_mystr
	push hl
	ld  e,c
	call    lb_fhexb
	pop hl

	ld b, #5
lb_omL:
	ld a,(hl)
	cp #'0'
	jr nz, lb_omEx
	inc hl
	djnz lb_omL
lb_omEx:
;	pop bc
;	pop de
	jp	_icputs

lb_fhexw:
	push    de
	ld  e,d
	call    lb_fhexb
	pop de
lb_fhexb:
	ld  a,e
	push    af
	rrca
	rrca
	rrca
	rrca
	call    lb_3
	pop af
lb_3:
	and #0xF
	add a,#'0'
	cp  #0x3A
	jr  c,lb_4
	add a,#7
lb_4:
	ld  (hl),a
	inc hl
	ret
    
lb_neghl:
    
	dec hl
	ld  a,l
	cpl
	ld  l,a
	ld  a,h
	cpl
	ld  h,a
	ret

;
	.area _DATA
    
lb_mystr:  .db #0,#0,#0,#0,#0,#0,#0;

	.area _CODE

LINL40	.equ 	0xF3AE

                
_Mode80::
        ld	a,#0x80    ;width 80
	jr	_setmode0
_Mode40::
        ld	a,#0x40    ;width 40
_setmode0:
        ld	(LINL40),a
	xor	a      
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x005F
	ret

FORCLR		.equ  #0xF3E9         ; foreground color 
BAKCLR		.equ  #0xF3EA         ; background color
BDRCLR		.equ  #0xF3EB         ; border color

_SetColor::
	push ix
	ld ix,#0
	add ix,sp
	ld a,4(ix)
	ld (FORCLR),a
	ld a,6(ix)
	ld (BAKCLR),a
	ld a,8(ix)
	ld (BDRCLR),a
	pop ix
	.db	#0xF7	;  RST 30h
	.db	#0x80
	.dw	#0x0062	; set color scheme by using FORCLR,BAKCLR,BDRCLR
	ret

CSRSW	.equ 0xFCA9	; address to set cursor display switch (0-not to show)        
CSTYLE	.equ 0xFCAA	; address to set cursor style (0-full,2-underline)
