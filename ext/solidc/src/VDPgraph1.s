;
;
;	VDPgraph1.h	- MSX1 graphics VDP functions (also MSX2 compatible)
;
;	Compile on SDCC for MSX
;
;	This works on MSXDOS, not BASIC ROM
;	Copy pixel data from memory RAM to video memory VRAM by using chip built in functions.
;	No slow BASIC graphics, real game must load data, manage rectangles of pixels in memory.
;
;	SCREEN 5 mode resolution 256 pixels x 212 lines x 16 colours (32kB for screen)
;
	.area _CODE

_SetScreen2::

	; Standard case from MSXDOS
	call	_vMSX	
	ld      a,(#_VDP)
	and	#0b11110001
	or      #0b00000010		; set M3 mode flags
	ld	(#_VDP),a
	call	_wrreg_0
	ld      a,(#_VDP+#1)		; enable interrupts, otherwise keyboard freezes
	or      #0b00100000
	ld	(#_VDP+#1),a
	call	_wrreg_1

	ld	a,#2	; Screen 2 MSX1,also MSX2
_isetscr:
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80	; BIOS slot (when nothing is loaded)  
	.dw	#0x005f	; CHGMOD CALL 5Fh
	pop	ix
	ret
	
_wrreg_0:	
	di
	out	(#0x99),a
	ld	a,#128+#0
	ei
	out     (#0x99),a
	ret
	
_SetScreen0::		; Set back Screen 0
	ld      a,(#_VDP)
	and	#0b11110001
	ld	(#_VDP),a
	xor	a      
	jr	_isetscr
	 
_DisableScreen::
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0041	; Disables screen display 
	pop	ix
	ld      a,(#_VDP+#1)
	and	#0b10111111
	ld	(#_VDP+#1),a
	call	_wrreg_1
	ret
	
_EnableScreen::
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0044	; Enables screen display 
	pop	ix
	ld      a,(#_VDP+#1)
	or      #0b01000000
	ld	(#_VDP+#1),a
	call	_wrreg_1
	ret
	
_ClearScreen::            

	xor	a
	push	ix	
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x00C3	; clears screen
	pop	ix
	ret

_SetBorderColor::               ; Sets border colour by A=Nr.  

	ld  hl,#2
	add hl,sp
	ld a,(hl)
            
	di
	out	(#0x99),a        ; a=[0..15]
	ld	a, #128+#7
	out	(#0x99),a        
	ei
	ret
	
GRPACX		.equ	#0xFCB7
GRPACY		.equ	#0xFCB9 

;
;	Puts string on graphics screen at position 
; 		(ignores \n\l\t and other text features)
_PutText::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld (GRPACX),hl
	ld l,6(ix)
	ld h,7(ix)
	ld (GRPACY),hl
	ld l,8(ix)
	ld h,9(ix)

lb_ptlp:	
	ld	a,(hl)
	or	a
	jr	z, lb_ptEx
  
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x008D	; GRPPRT displays character on graphics screen
	
	inc	hl
	jr	lb_ptlp
lb_ptEx:
	pop ix
	ret
	
	
;---------------------------------------- 2 pixel writing/reading mode	
;
; VDP write/read at address
;
_pos_byXY:		; Procedure calculates hl offset and sets VDP for writing
	di
	ld	a,e	; e=y[0..191]
	and	#248	; /8
	rra
	rra
	rra
	ld	h,a	; each 8 lines = 256 bytes
	ld	a,d	; d=x[0..255]
	and	#248
	ld	l,a	; + 8*int(x/8)
	ld	a,e
	and	#7
	or	l	; + y mod 8
	ld	l,a
	ei
	ret
	 
; This prepares for "pixeling",  HL contains initial address
_VDPwrite:
	xor	a
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0053		; SETWRT Sets up the VDP for writing with HL address
	pop	ix
	ret         


_VDPput8pixels:		; Put 8 pixels by sending one byte
	out (#0x98),a		; send this sequentially
	ret

_VDPread:
	xor	a
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0050		; SETRD Sets up the VDP for reading with HL address
	pop	ix
	ret
	
_VDPget8pixels:           	; Get 8 pixels
	in	a,(#0x98)	; read this sequentially
	ret

	
FORCLR		.equ  #0xF3E9         ; foreground color 
BAKCLR		.equ  #0xF3EA         ; background color
BDRCLR		.equ  #0xF3EB         ; border color

_SetColors::
	push	ix
	ld ix,#0
	add ix,sp
	ld a,4(ix)
	ld (FORCLR),a
	ld a,6(ix)
	ld (BAKCLR),a
	ld a,8(ix)
	ld (BDRCLR),a
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0062	; set color scheme by using FORCLR,BAKCLR,BDRCLR
	pop	ix
	ret

;--------------------
;
; Basic Keyboard functions
;
_WaitForKey::
	call	_waitkey
	ld	l,a
	ld	h,#0
	ret
	
_waitkey:
		; wait for keypress
	di
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x009f
	ei
	
_ClearKeyBuffer::
		; clear key buffer after
	di
	push	af
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0156
	pop	af
	ei
	ret

_Inkey::
		; detects if there is a keypress
	di
	.db	#0xF7	; RST 30h
	.db	#0x80 
	.dw	#0x009c
	ei
	jr	z,lb_ink0	; if NO then return
	jr	_WaitForKey	; if YES then detects code
lb_ink0:
	ld l, a
	ld h, a	;=0
	ret
 
_keyboard_read::
	push	ix
	in	a,(#0xAA)
	and	#0xF0		; only change bits 0-3
	or	#8		; row 8
	out	(#0xAA),a
	in	a,(#0xA9)	; read row into A
	cpl
	ld	l,a
	ld	h,#0
	pop	ix
	ret 
	
;========================================================
;
;	Simply check MSX1 or MSX2 without touching VDP
;

EXBRSA	.equ	0xFAF8			; the slot of SUB-ROM (0 for MSX1)

_vMSX::
	ld	a, (EXBRSA)	; do not touch TMS9918A of MSX1, just obtain technical slot presence
	or	a
	jr	nz, lb_vrYm
	ld	a,#1		; MSX1
	jr	lb_vrEx
lb_vrYm:
	ld	a,#2		; MSX2 and above
lb_vrEx:
	ld	l,a
	ld	h,#0
	ret
	      
;
; Save and restore VDP internal registers
;
_Save_VDP::
			; let's have initial 0
	ld	hl,#_VDP+#0
	ld	de,#_VDP_0+#0
	ld	bc,#8
	ldir
	ret

_Restore_VDP::
	ld	bc,#0x0800
	ld	hl,#_VDP_0
	call    lb_rstVdp
	ld      bc,#0x1008
	ret
lb_rstVdp:
	ld      a,(hl)
	inc     hl
	di
	out     (#0x99),a
	ld      a,c
	or      #0x128
	ei
	out     (#0x99),a
	inc     c
	djnz    lb_rstVdp
	ret

	.area	_XDATA

_VDP:		.dw  #0,#0,#0,#0,#0,#0,#0,#0
_VDP_0:		.dw  #0,#0,#0,#0,#0,#0,#0,#0

	.area	_CODE

;
; A dumb memory to screen write
;

_Write_Scr::

	push ix
	ld ix,#0
	add ix,sp

	ld l,6(ix)
	ld h,7(ix)
	push	hl
	
	ld l,4(ix)
	ld h,5(ix)
	push	hl

	di
	ld	hl,#0
	call	_VDPwrite
	pop	hl
	ld	de,#0x0000	; patterns
	ld	bc,#0x1800	;32 x 192 lines
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x005C	; LDIRVM 	Block transfer to VRAM from memory
	
	pop	hl
	ld	de,#0x2000	; colours
	ld	bc,#0x1800	;32 x 192 lines
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x005C	; LDIRVM 	Block transfer to VRAM from memory 
	ei
	pop ix
	ret 

	
;
; A dumb screen to memory read
;

_Read_Scr::

	push ix
	ld ix,#0
	add ix,sp

	ld l,6(ix)
	ld h,7(ix)
	push	hl
	
	ld l,4(ix)
	ld h,5(ix)
	push	hl
	
	di
	ld	hl,#0
	call	_VDPread
	pop	de
	ld	hl,#0x0000	; patterns
	ld	bc,#0x1800	;32 x 192 lines
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0059	; LDIRMV 	Block transfer to memory from VRAM
	
	pop	de
	ld	hl,#0x2000	; colours
	ld	bc,#0x1800	;32 x 192 lines
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0059	; LDIRMV 	Block transfer to memory from VRAM
	ei
	
	pop ix
	ret

;
; BLOCK read to memory
;
	
_Read_Block::
	push ix
	ld ix,#0
	add ix,sp

	call	lb_ld_cpyXY
	
	ld l,12(ix)
	ld h,13(ix)	; patterns
	push	ix
lb_bclp0:
	push	bc
	push	de
lb_bclp1:
	push	hl
	call	_pos_byXY
	di
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x004A ; RDVRM 	Reads the VRAM address by [HL].
	ei
	pop	hl
	ld	(hl),a
	inc	hl
	call	lb_d_add8
	djnz	lb_bclp1
	pop	de
	pop	bc
	inc	e
	dec	c
	jr	nz,lb_bclp0
	pop	ix
	
	call	lb_ld_cpyXY
	
	ld l,14(ix)
	ld h,15(ix)	;colors
lb_bclp0a:
	push	bc
	push	de
lb_bclp1a:
	push	hl
	call	_pos_byXY
	push	bc
	ld	bc,#0x2000	; colours are mapped +0x2000
	add	hl,bc
	pop	bc
	di
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x004A ; RDVRM 	Reads the VRAM address by [HL].
	ei
	pop	hl
	ld	(hl),a
	inc	hl
	call	lb_d_add8
	djnz	lb_bclp1a
	pop	de
	pop	bc
	inc	e
	dec	c
	jr	nz,lb_bclp0a
	
	pop ix
	ret

;
; BLOCK write from memory to screen
;
_Write_Block::
	push ix
	ld ix,#0
	add ix,sp

	call	lb_ld_cpyXY
	
	ld l,12(ix)
	ld h,13(ix)	; patterns
	push	ix
lb_bclp4:
	push	bc
	push	de
lb_bclp5:
	ld	a,(hl)
	ld	(#_wr_by),a
	push	hl
	call	_pos_byXY
	ld	a,(#_wr_by)
	di
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x004D ; WRTVRM  	Write to the VRAM address by [HL].
	ei
	pop	hl
	inc	hl
	call	lb_d_add8
	djnz	lb_bclp5
	pop	de
	pop	bc
	inc	e
	dec	c
	jr	nz,lb_bclp4
	pop	ix
	
	call	lb_ld_cpyXY
	
	ld l,14(ix)
	ld h,15(ix)	;colors
lb_bclp4a:
	push	bc
	push	de
lb_bclp5a:
	ld	a,(hl)
	ld	(#_wr_by),a
	push	hl
	call	_pos_byXY
	push	bc
	ld	bc,#0x2000	; colours are mapped +0x2000
	add	hl,bc
	pop	bc
	ld	a,(#_wr_by)
	di
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x004D ; WRTVRM  	Write to the VRAM address by [HL].
	ei
	pop	hl
	inc	hl
	call	lb_d_add8
	djnz	lb_bclp5a
	pop	de
	pop	bc
	inc	e
	dec	c
	jr	nz,lb_bclp4a
	
	pop ix
	ret

lb_ld_cpyXY:

	ld b,8(ix)	;dx
	ld c,10(ix)	;dy
	
	ld d,4(ix)	; X,Y
	ld e,6(ix)
	
lb_b_div8:
	ld	a,b
	and	#248
	rrca
	rrca
	rrca		; /8
	ld	b,a
	ret
	
lb_d_add8:
	ld	a,d
	add	#8
	ld	d,a
	ret
	
	.area	_XDATA

_wr_by:		.db	#0
	
	.area	_CODE
	
;****************************************************************
; Get pattern at x,y.

;
; int get8px(int X, int Y);
;
_get8px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	call	_igB8px
	ld	l,a
	ld	h,#0
	pop ix
	ret
;
; int get1px(int X, int Y);
;
_get1px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	call	_iget1px
	pop ix
	ld	l,a
	ld	h,#0
	ret
_iget1px:
	ld	hl,#_px8bits
	ld	b,#0
	ld	a,d
	and	#7
	ld	c,a
	add	hl,bc
	ld	b,(hl)
	call	_igB8px
	and	b
	ret
	
;****************************************************************
; Set pattern at x,y.

;
; void set8px(int X, int Y);
;
_set8px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	ld b,#0xFF
	call	_iset8px
	pop ix
	ret
;
; void set1px(int X, int Y);
;
_set1px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	call	_iset1px
	pop ix
	ret
_iset1px:
	ld	hl,#_px8bits
	ld	b,#0
	ld	a,d
	and	#7
	ld	c,a
	add	hl,bc
	ld	b,(hl)
	call	_iset8px
	ret
	
_igB8px:		; get byte from VRAM
	push	bc
	call	_pos_byXY
	call	_VDPread
	call	_VDPget8pixels
	pop	bc
	ret
	
_iset8px:
	call	_igB8px
	or	b
	ld	c,a
	call	_VDPwrite
	ld	a,c		; write new pattern of 8 pixels
	call	_VDPput8pixels
	ret

;****************************************************************
; Clear pattern at x,y.

;
; void clear8px(int X, int Y);
;
_clear8px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	ld b,#0x00
	call	_iset8px
	pop ix
	ret
	
;
; void clear1px(int X, int Y);
;
_clear1px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	call	_iclear1px
	pop ix
	ret
_iclear1px:
	ld	hl,#_px8bits
	ld	b,#0
	ld	a,d
	and	#7
	ld	c,a
	add	hl,bc
	
	ld	a,(hl)
	xor	#0xFF		; invert
	ld	b,a
	call	_igB8px
	and	b		; remove pixel
	ld	c,a
	call	_VDPwrite
	ld	a,c		; write new pattern of 8 pixels
	call	_VDPput8pixels	
	ret
	
	.area	_XDATA

_px8bits:	.db #0x80,#0x40,#0x20,#0x10,#0x08,#0x04,#0x02,#0x01

	.area	_CODE

;****************************************************************
; Get colour at x,y.
;	void	getCol8px( int x, int y, pxColor *C )
;
_getCol8px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	ld l,8(ix)
	ld h,9(ix)
	push	hl
	pop	ix
	call	_igetCol8px
	ld	b,a
	xor	a
	ld	1(ix),#0
	ld	3(ix),#0
	ld	a,b
	and	#0x0F
	ld	2(ix),a
	ld	a,b
	and	#0xF0
	rra
	rra
	rra
	rra
	ld	0(ix),a
	pop ix
	ret
	
_igetCol8px:
	call	_pos_byXY
	ld	bc,#0x2000	; colours are mapped +0x2000
	add	hl,bc
	call	_VDPread
	call	_VDPget8pixels
	ret

;****************************************************************
; Set colour at x,y.
;	void	setCol8px( int x, int y, pxColor *C )
;
_setCol8px::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	ld l,8(ix)
	ld h,9(ix)
	push	hl
	pop	ix
	ld	a,0(ix)
	rla
	rla
	rla
	rla
	or	2(ix)
	call	_isetCol8px
	pop ix
	ret
	
_isetCol8px:
	push	af
	call	_pos_byXY
	ld	bc,#0x2000	; colours are mapped +0x2000
	add	hl,bc
	call	_VDPwrite
	pop	af
	call	_VDPput8pixels
	ret

;****************************************************************
;	Set coloured pixel at x,y
;	Ignore 8pt same colour scheme. 
;
;	void	PSET( int x, int y, int color )
;

_PSET::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	ld b,8(ix)
	call	_ipset
	pop ix
	ret
_ipset:	
	push	bc
	ld	a,(#_ln_y8px)
	or	a
	jr	z,lb_lnpset
	xor	a
	ld	(#_ln_y8px),a
	ld b,#0xFF
	call	_iset8px
	jr	lb_lnpcol
lb_lnpset:	
	call	_iset1px
lb_lnpcol:
	call	_igetCol8px
	and	#0x0F
	ld	c,a
	pop	af
	and	#0x0F
	rla
	rla
	rla
	rla
	or	c
	ld	c,a
	call	_VDPwrite
	ld	a,c
	call	_VDPput8pixels
	ret
_ipsetsv:			; saves registers
	push	de
	push	hl
	push	bc
	call	_ipset
	pop	bc
	pop	hl
	pop	de
	ret
	
;****************************************************************
;	Get coloured pixel at x,y
;	Ignore 8pt same colour scheme. 
;
;	int	POINT( int x, int y )
;
		
_POINT::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	call	_ipoint
	pop ix
	ld	l,a
	ld	h,#0
	ret
_ipoint:	
	call	_iget1px
	or	a
	jr	z,lb_Pt0
	call	_igetCol8px
	rra
	rra
	rra
	rra
	jr	lb_PtExt
lb_Pt0:
	call	_igetCol8px
lb_PtExt:
	and	#0x0F
	ret
	
; ----------------------------------------------------------
; void LINE( int X,  int Y, int X2,  int Y2, int color )
; ----------------------------------------------------------

_LINE::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-12
	add	hl,sp
	ld	sp,hl
;c#132: unsigned char xo = ( X2<X ? 1 : 0 );
	ld	a,8 (ix)
	sub	a, 4 (ix)
	ld	a,9 (ix)
	sbc	a, 5 (ix)
	jp	PO, lb_ln87
	xor	a, #0x80
lb_ln87:
	jp	P,lb_ln26
	ld	c,#0x01
	jr	lb_ln27
lb_ln26:
	ld	c,#0x00
lb_ln27:
;c#133: unsigned char yo = ( Y2<Y ? 1 : 0 );
	ld	a,10 (ix)
	sub	a, 6 (ix)
	ld	a,11 (ix)
	sbc	a, 7 (ix)
	jp	PO, lb_ln88
	xor	a, #0x80
lb_ln88:
	jp	P,lb_ln28
	ld	a,#0x01
	jr	lb_ln29
lb_ln28:
	ld	a,#0x00
lb_ln29:
	ld	-12 (ix),a
;c#135: xx = (xo==0 ? X2-X : X-X2);
	ld	a,c
	sub	a,#0x01
	ld	a,#0x00
	rla
	ld	d,a
	ld	h,8 (ix)
	ld	l,4 (ix)
	ld	a,d
	or	a, a
	jr	Z,lb_ln30
	ld	a,h
	sub	a, l
	jr	lb_ln31
lb_ln30:
	ld	a,l
	sub	a, h
lb_ln31:
	ld	-4 (ix),a
;c#136: yy = (yo==0 ? Y2-Y : Y-Y2);
	ld	a,-12 (ix)
	sub	a,#0x01
	ld	a,#0x00
	rla
	ld	d,a
	ld	h,10 (ix)
	ld	l,6 (ix)
	ld	a,d
	or	a, a
	jr	Z,lb_ln32
	ld	a,h
	sub	a, l
	jr	lb_ln33
lb_ln32:
	ld	a,l
	sub	a, h
lb_ln33:
	ld	h,a
;c#137: dx = xx; dy = yy;
	ld	a,-4 (ix)
	ld	-3 (ix),a
	ld	-2 (ix),#0x00
	ld	e,h
	ld	d,#0x00
;c#138: if(xx>yy)
	ld	a,h
	
	push	af
	; save flag if yy==0
	or	a
	jr	z, lb_lny0
	xor	a
	dec	a
lb_lny0:
	inc	a
	ld	(#_ln_yy0),a
	pop	af
	
	sub	a, -4 (ix)
	ld	a,#0x00
	rla
	ld	-1 (ix), a
	or	a, a
	jr	Z,lb_ln02
;c#140: n = xx;
	ld	a,-4 (ix)
	ld	-7 (ix),a
;c#141: dy<<=8;
	ld	h,e
	ld	l,#0x00
;c#142: k = dy/dx;
	push	bc
	ld	e,-3 (ix)
	ld	d,-2 (ix)
	
	ld	d,e
	call	Div_HL_D
	
	pop	bc
	ld	-9 (ix),l
	ld	-8 (ix),h
	jr	lb_ln46
lb_ln02:
;c#146: n = yy;
	ld	-7 (ix),h
;c#147: dx<<=8;
	ld	h,-3 (ix)
	ld	l,#0x00
;c#148: k = dx/dy;
	push	bc
	
	ld	a,e
	or	a
	jr	z,lb_lnDv0	; skip /0
	ld	d,e
	call	Div_HL_D
lb_lnDv0:
	
	pop	bc
	ld	-9 (ix),l
	ld	-8 (ix),h
;c#152: while(i<=n)
lb_ln46:
	ld	e,#0x00
lb_ln21:
	ld	a,-7 (ix)
	sub	a, e
	jp	C,lb_ln24
;c#154: r = i;
	ld	-11 (ix),e
	ld	-10 (ix),#0x00
;c#155: xp = X; yp = Y;
	ld	a,4 (ix)
	ld	-5 (ix),a
	ld	a,6 (ix)
	ld	-6 (ix),a
;c#156: if(n!=0)
	ld	a,-7 (ix)
	or	a, a
	jp	Z,lb_ln20
;c#160: j=(unsigned char)((r*k)>>8);
	push	bc
	push	de
	ld	e,-9 (ix)
	ld	d,-8 (ix)
	ld	a,-11 (ix)
	call	DE_Times_A
	pop	de
	pop	bc
;c#161: if(xx>yy)
	ld	a,-1 (ix)
	or	a, a
	jr	Z,lb_ln17
;c#163: if(xo==0) xp += i; else xp -= i;
	ld	a,c
	or	a, a
	jr	NZ,lb_ln05
	ld	a,-5 (ix)
	add	a, e	
	ld	-5 (ix),a

	; this makes faster when horizontal lines (for filled rectangles)
	
	ld	a,(#_ln_yy0)
	or	a
	jr	z,lb_lnNo0
	
	ld	a,-7 (ix)	; if(i+7<=n)
	sub	#7
	jp	C,lb_lnNo0	
	sub	e
	jp	C,lb_lnNo0

	ld	a,-5 (ix)	; if((xp&7)==0)
	and	#7
	jr	nz,lb_lnNo0
	
	ld	a,c		; if right direction
	or	a
	jr	nz,lb_lnNo0
	
	jr	lb_lnf1

	
lb_lnf1:
	ld	a, e		; then i+=7
	add	#7
	ld	e, a
	
	ld	a,#1
	ld	(#_ln_y8px),a
	
lb_lnNo0:
	; ----- 8px pset is much faster
	
	jr	lb_ln06
lb_ln05:
	ld	a,-5 (ix)
	sub	a, e
	ld	-5 (ix),a

	; this makes faster when horizontal lines (for filled rectangles)
	
	ld	a,(#_ln_yy0)
	or	a
	jr	z,lb_lnNo0
	
	ld	a,-7 (ix)	; if(i+7<=n)
	sub	#7
	jp	C,lb_lnNo0
	sub	e
	jp	C,lb_lnNo0

	ld	a,-5 (ix)	; if((xp&7)==0)
	and	#7
	cp	#7
	jr	nz,lb_lnNo0
	
	ld	a,c		; if left direction
	or	a
	jr	z,lb_lnNo0
	
	jr	lb_lnf1
	
lb_ln06:
;c#164: if(yo==0) yp += j; else yp -= j;
	ld	a,-12 (ix)
	or	a, a
	jr	NZ,lb_ln08
	ld	a,-6 (ix)
	add	a, h
	ld	-6 (ix),a
	jr	lb_ln20
lb_ln08:
	ld	a,-6 (ix)
	sub	a, h
	ld	-6 (ix),a
	jr	lb_ln20
lb_ln17:
;c#168: if(yo==0) yp += i; else yp -= i;
	ld	a,-12 (ix)
	or	a, a
	jr	NZ,lb_ln11
	ld	a,-6 (ix)
	add	a, e
	ld	-6 (ix),a
	jr	lb_ln12
lb_ln11:
	ld	a,-6 (ix)
	sub	a, e
	ld	-6 (ix),a
lb_ln12:
;c#169: if(xo==0) xp += j; else xp -= j;
	ld	a,c
	or	a, a
	jr	NZ,lb_ln14
	ld	a,-5 (ix)
	add	a, h
	ld	-5 (ix),a
	jr	lb_ln20
lb_ln14:
	ld	a,-5 (ix)
	sub	a, h
	ld	-5 (ix),a
lb_ln20:
;c#172: PSET( xp, yp, color );

	push	bc
	push	de

	ld	e,-6 (ix)
	ld	d,-5 (ix)
	ld	b,12 (ix)
	
	call	_ipset

	pop	de
	pop	bc
	
;c#173: i++;
	inc	e
	jp	lb_ln21
lb_ln24:
	ld	sp, ix
	pop	ix
	ret

_iline:
	ld	c,b
	ld	b,#0
	push	bc
	ld	c,e
	push	bc
	ld	c,d
	push	bc
	ld	c,l
	push	bc
	ld	c,h
	push	bc
	call	_LINE
	ld	hl,#10
	add	hl,sp
	ld	sp,hl
	ret


DE_Times_A:			; HL = DE * A
	ld	hl,#0		; Use HL to store the product
	ld	b,#8		; Eight bits to check
ml_loop:
	add	hl,hl
	rlca			; Check most-significant bit of accumulator
	jr	nc,ml_skip	; If zero, skip addition
	add	hl,de
ml_skip:
	djnz	ml_loop
	ret

Div_HL_D:			; HL = HL / D, A = remainder
	xor	a		; Clear upper eight bits of AHL
	ld	b, #16		; Sixteen bits in dividend
div_loop:
	add	hl,hl		; Do a SLA HL. If the upper bit was 1, the c flag is set
	rla			; This moves the upper bits of the dividend into A
	jr	c, div_overflow
	cp	d		; Check if we can subtract the divisor
	jr	c, div_skip	; Carry means D > A
div_overflow:
	sub	d		; Do subtraction for real this time
	inc	l		; Set the next bit of the quotient (currently bit 0)
div_skip:
	djnz	div_loop
	ret

;---------------------------
; 
;	Draws rectangle (H,L)-(D,E) with color B, log-op A
;
_RECT::
	push ix
	ld ix,#0
	add ix,sp
	
	ld h,4(ix)
	ld l,6(ix)
	ld d,8(ix)
	ld e,10(ix)
	ld b,12(ix)
	ld c,14(ix)
	pop ix
	
	xor	a
lb_svfl:
	ld	(#_rect_fill),a
	ld	a,c	
	cp	#0xff		; if fill case
	jr	nz, lb_rNfl
	xor	a
	ld	c,a
	inc	a
	jr	lb_svfl
lb_rNfl:
	push	de
	push	hl
	push	de
	ld	e,l
	call	lb_rctl
	pop	hl
	call	lb_rctl
	pop	de
	push	de
	ld	e,l
	call	lb_rctl
	pop	hl
	call	lb_rctl
	pop	de
	
	ld	a,(#_rect_fill)
	or	a
	ret	z
			; fill rectangle with colour
lb_rcLp:	
	ld	a,l
	sub	e
	jr	z, lb_rcOK
	jr	nc,lb_rcm
	inc	l
	inc	l
lb_rcm:
	dec	l
	push	de
	ld	e,l
	call	lb_rctl
	pop	de
	jr	lb_rcLp
lb_rcOK:
	ret
	
lb_rctl:	
	push	hl
	push	de
	push	bc
	ld	a,c
	call	_iline
	pop	bc
	pop	de
	pop	hl
	ret


	.area	_XDATA
_rect_fill:	.db #0
_lpaintHL:	.dw #0
_ln_yy0:	.db #0
_ln_y8px:	.db #0
	.area	_CODE
	
;---------------------------
; Paints from the point (x:H, y:L), color:E
; Not 100% correct. Basic has better PAINT code.
; There is SRCH (colour code search) VDP algorithm that
; should be implemented here instead of this crap.
;
_PAINT::
	
	push ix
	ld ix,#0
	add ix,sp
	
	ld h,4(ix)
	ld l,6(ix)
	ld e,8(ix)
	pop ix
	
		; this is way to limit stack depth, it is better then dumb crash
_ptAgain:	
	ld	bc, #0x2000	; calculate depth, limit
	call	_paintRR
	
	ld	hl,(#_lpaintHL)
	ld	a,b
	or	c
	jr	z,_ptAgain	; if bc==0 then try paint at last position
	ret
	
_paintRR:
	push	hl
	push	de
	push	bc
	ld	b,e
	ex	de,hl		; de = X,Y
	call	_ipset
	pop	bc
	pop	de
	pop	hl
	ld	(#_lpaintHL),hl	; will continue after all returns (Call SP>SP>SP...>..0x8000 crash at)
lb_ptY0:	
	ld	a,l
	or	a
	jr	z,lb_ptX0
	dec	l
	call	recIfPaint
	inc	l
lb_ptX0:	
	ld	a,h
	or	a
	jr	z,lb_ptY2
	dec	h
	call	recIfPaint
	inc	h
lb_ptY2:
	ld	a,l
	cp	#191
	jr	z,lb_ptX2
	inc	l
	call	recIfPaint
	dec	l
lb_ptX2:
	ld	a,h
	cp	#255
	jr	z,lb_ptOk
	inc	h
	call	recIfPaint
	dec	h	
lb_ptOk:
	ld	a,b
	or	c
	ret	z	; if bc==0 then just return
	jr	lb_rbc

recIfPaint:
	ld	a,b
	or	c
	ret	z	; if bc==0 then just return
	
	dec	bc	
	push	hl
	push	de
	push	bc
	ex	de,hl		; de = X,Y
	call	_iget1px
	pop	bc
	pop	de
	pop	hl
	or	a
	jr	nz,lb_rbc
	jp	_paintRR 
lb_rbc:
	inc	bc
	ret
	
;--------------------------------------------
;	S P R I T E S
;--------------------------------------------

;
; Set 8 x 8 sprites
;
_Sprites_8::
	ld      a,(#_VDP+#1)
	and      #0b11111101
	ld      (#_VDP+#1),a
	call	_wrreg_1
	xor	a
	ld	(#_spr_16),a
	ret
	
_wrreg_1:
	di
	out     (#0x99),a
	ld      a,#128+#1
	ei
	out     (#0x99),a
	ret
;
; Set 16 x 16 sprites
;
_Sprites_16::
	ld      a,(#_VDP+#1)
	or      #0b00000010
	ld      (#_VDP+#1),a
	call	_wrreg_1
	ld	a,#1
	ld	(#_spr_16),a
	ret
	
_ResetSprites::
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80	;
	.dw	#0x0069	; CALL 69h SCRMOD
	pop	ix
	ret

;
; Set sprites to double size
;
_SpritesDoubleSized::
	ld      a,(#_VDP+#1)
	and     #0b11111100 
	or      #0b00000001
	ld      (#_VDP+#1),a
	jr	_wrreg_1
;
; Set back to normal small size sprite
;	
_SpritesSmall::
	ld      a,(#_VDP+#1)
	and	#0b11111110
	ld      (#_VDP+#1),a
	jr	_wrreg_1

;  VRAM default memory map of sprites
; -------------------------------------------------------------------------------
; | 0x1B00 - 0x1B7F		128 bytes for sprite attributes			|
; | 0x3800 - 0x3FFF		2048 (256 x 8) bytes for sprite patterns	|
; -------------------------------------------------------------------------------

SPRITES_PATTERN		.equ	#0x3800
SPRITES_ATTRIBS		.equ	#0x1B00


;--------------------------------------------------------
; Define new pattern for sprites
;
;	Number of pattern 0..255	(2Kb for all pattern data)
;	Address of data to write to sprite VRAM pattern table (8 or 16 bytes)
;--------------------------------------------------------

_SpritePattern::

	ld	hl, #SPRITES_PATTERN
	ld	(#_spr_thb),hl
	
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix)
	ld d,7(ix)
	pop ix

	push	de
	ld	e,l	
	ld	hl, (#_spr_thb)		
	call	Spr_locTb	; find position in table
	ld	b,c		; 8 or 32, depends on sprite size, or 8 or 16 if colour settings
	pop	de

Spr_wr_vram:	
		;write to VRAM table
	di
	call	_VDPwrite
	ex	de,hl
	ld	c,#0x98
	ld	a,(hl)
	otir
	
	ld	hl,#0
	call	_VDPwrite
	ei
	ret
		
	; positions HL to sprite number in reg-e
Spr_locTb:
	ld	bc,#16
	ld	c,#8
	ld	a,(#_spr_16)
	or	a
	jr	z,Spr_TbSpk		; if 8x8 -> 8 
	ld	c,#32			; if 16x16 ->32
	ld	a,e
	and	#252
	rrca				; e/=4 palette number
	rrca
	ld	e,a
	
Spr_TbSpk:
	dec	e
	ret	m
	add	hl,bc
	jr	Spr_TbSpk

;
; Set sprite attributes
;
;	Number of sprite
;	Pattern [0..255] created before
;	X [0..255]
;	Y [0..191]
;
_SpriteAttribs::
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld a,6(ix)
	ld (#_spr_atrb+#2),a
	ld a,8(ix)
	ld (#_spr_atrb+#1),a
	ld a,10(ix)
	ld (#_spr_atrb+#0),a
	ld a,12(ix)
	ld (#_spr_atrb+#3),a
	pop ix

	ld	hl, #SPRITES_ATTRIBS
	ld	bc,#4
	call	Spr_TbSpk	; position HL
	ld	de, #_spr_atrb	
	ld	b,#4
	jr	Spr_wr_vram

_Sprite32bytes::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix

	inc	hl
	ld	de,#_spr_32b
	ld	c,#1
lb_spr0qrt:
	ld	b,#16
lb_spr1qrt:
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	hl
	inc	de
	djnz	lb_spr1qrt
	dec	c
	jp	m,lb_sprQ4
	push	bc
	ld	bc,#33
	scf
	ccf
	sbc	hl,bc
	pop	bc
	jr	lb_spr0qrt
lb_sprQ4:
	ld	hl,#_spr_32b
	ret
	
		.area	_XDATA

_spr_thb:	.dw #0		
_spr_16:	.db #0		; keep value here, default 8x8
_spr_atrb:	.db #0,#0,#0,#0
_spr_32b:	.ds #32

		.area	_CODE
;
; DRAW function with syntax
;
_DRAW::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
	
lb_drwLp:
	ld	a,(_drw_m)
	or	a
	jr	nz,lb_drwMmv
	
	ld	de,(_drw_YX)
lb_drwMmv:
	ld	a,(hl)
	or	a
	jp	z, lb_drwEx
	cp	#97
	jr	c,lb_drwUpc
	sub	#32
lb_drwUpc:
lb_drw0:
	cp	#'U'
	jr	nz, lb_drw1
	call	_drw_dcY
	jr	flb_drwQ
lb_drw1:
	cp	#'D'
	jr	nz, lb_drw2
	call	_drw_icY
	jr	flb_drwQ
lb_drw2:
	cp	#'L'
	jr	nz, lb_drw3
	call	_drw_dcX
	jr	flb_drwQ
lb_drw3:
	cp	#'R'
	jr	nz, lb_drw4
	call	_drw_icX
	jr	flb_drwQ
lb_drw4:
	cp	#'E'
	jr	nz, lb_drw5
	call	_drw_icX
	call	_drw_dcY
	jr	flb_drwQ
lb_drw5:
	cp	#'F'
	jr	nz, lb_drw6
	call	_drw_icX
	call	_drw_icY
	jr	flb_drwQ
lb_drw6:
	cp	#'G'
	jr	nz, lb_drw7
	call	_drw_dcX
	call	_drw_icY
	jr	flb_drwQ
lb_drw7:
	cp	#'H'
	jr	nz, lb_drw8
	call	_drw_dcX
	call	_drw_dcY
	jr	flb_drwQ

flb_drwQ:	jp	lb_drwQ
flb_drwQp:	jp	lb_drwQp
flb_drwScnOp:	jp	lb_drwScnOp

lb_drw8:
	cp	#'B'
	jr	nz, lb_drw9
	ld	a,#1
	ld	(_drw_B),a
	jr	flb_drwQp
lb_drw9:
	cp	#'N'
	jr	nz, lb_drw10
	ld	a,#1
	ld	(_drw_N),a
	jr	flb_drwQp

lb_drw10:
	cp	#'S'
	jr	nz, lb_drw11
	call	_drw_gLnQ		; c=scale count
	ld	a,c
	and	#252
	rrca
	rrca				; scale/4 = pixels
	or	a
	jr	nz,lb_drwScs
	inc	a
lb_drwScs:
	ld	(_drw_Scale),a
	jr	flb_drwScnOp
lb_drw11:
	cp	#'C'
	jr	nz, lb_drw12
	call	_drw_gLn		; read colour number
	ld	a,(_drw_Ln)
	ld	(#FORCLR),a
	jr	flb_drwScnOp

lb_drw12:
	cp	#'M'
	jr	nz, lb_drw13
	ld	a,#1
	ld	(_drw_m),a
	call	_drw_gLn		; read X
	ld	a,(_drw_sg)
	or	a
	jr	nz,_drw_relX
	ld	d,#0			; absolute X, not +cnt
_drw_relX:
	cp	#2
	jr	z,_drw_relmX
	call	_drw_icX
	jr	_drw_releX
_drw_relmX:
	call	_drw_dcX
_drw_releX:
	jr	lb_drwScnOp
lb_drw13:
	cp	#','
	jr	nz, lb_drw14
	call	_drw_gLn		; read Y
	ld	a,(_drw_sg)
	or	a
	jr	nz,_drw_relY
	ld	e,#0			; absolute Y, not +cnt
_drw_relY:
	cp	#2
	jr	z,_drw_relmY
	call	_drw_icY
	jr	_drw_releY
_drw_relmY:
	call	_drw_dcY
_drw_releY:
	xor	a
	ld	(_drw_m),a
	jr	lb_drwQ
lb_drw14:

	jr	lb_drwScnOp
	
lb_drwQ:
	ld	a,(_drw_m)	; if M command, save till ','
	or	a
	jr	nz,lb_drwQp
	ld	a,#1
	ld	(_drw_f),a
lb_drwQp:
	push	hl
	ld	hl,(_drw_YX)
	ld	a,(_drw_B)
	or	a
	jr	nz,lb_drwSkB
	ld	a,(#FORCLR)
	ld	b,a			; set colour
	ld	c,#0			; logical = 0
	call	lb_rctl			; draw line
lb_drwSkB:
	ld	a,(_drw_N)
	or	a
	jr	nz,lb_drwSkN
	ld	(_drw_YX),de		; save new position
lb_drwSkN:
	pop	hl
	
lb_drwScnOp:
	ld	a,(_drw_f)
	or	a
	jr	z,lb_drwcl
	xor	a
	ld	(_drw_f),a
	ld	(_drw_B),a
	ld	(_drw_N),a
lb_drwcl:

	inc	hl
	jp	lb_drwLp		; loop

lb_drwEx:

	ret

		; new position of point inc,dec
_drw_dcX:
	ld	a,d
	call	_drw_dec
	ld	d,a
	ret
_drw_dcY:
	ld	a,e
	call	_drw_dec
	ld	e,a
	ret
_drw_icX:
	ld	a,d
	ld	c,#255
	call	_drw_inc
	ld	d,a
	ret
_drw_icY:
	ld	a,e
	ld	c,#191
	call	_drw_inc
	ld	e,a
	ret

	
_drw_dec:				; count x scale dec
	call	_drw_gLnQ		; c=count
_drw_dcylpc:	
	call	_drw_ldb		; b=scale
_drw_dcylp:
	or	a
	ret	z
	dec	a
	djnz	_drw_dcylp
	dec	c
	dec	c
	jp	m,_drw_dcyEx
	inc	c
	jr	_drw_dcylpc
_drw_dcyEx:
	ret
	
_drw_inc:
	cp	c
	ret	z

	push	de
	ld	e,c
					; count x scale inc
	call	_drw_gLnQ		; c=count
_drw_icylpc:
	call	_drw_ldb		; b=scale
_drw_icylp:	
	inc	a
	cp	e
	jr	z,_drw_icyEx
	djnz	_drw_icylp
	dec	c
	dec	c
	jp	m,_drw_icyEx
	inc	c
	jr	_drw_icylpc
_drw_icyEx:
	pop	de
	ret

_drw_ldb:
	push	af
	ld	a,(_drw_m)
	or	a
	jr	z,_drw_ldb2
	
	ld	a,(_drw_sg)
	or	a
	jr	nz,_drw_ldb2
	ld	a,#1
	jr	_drw_ldbE
_drw_ldb2:
	ld	a,(_drw_Scale)
_drw_ldbE:
	ld	b,a
	pop	af
	ret

_drw_gLnQ:			; number is 1 or more
	push	af
	call	_drw_gLn
	ld	a,(_drw_Ln)
	or	a
	jr	nz,_drw_glnq
	inc	a
	ld	(_drw_Ln),a
_drw_glnq:
	ld	c,a	
	pop	af
	ret
	
_drw_gLn:			; get number if is
	push	hl
	push	af
	push	bc
	
	inc	hl
	ld	a,(hl)
	cp	#'+'
	jr	z,lb_drwLnP
	cp	#'-'
	jr	z,lb_drwLnM
	xor	a
	dec	hl
	jr	_drw_Lnc
lb_drwLnP:
	ld	a,#1
	jr	_drw_Lnc
lb_drwLnM:
	ld	a,#2	
_drw_Lnc:	
	ld	(_drw_sg),a
	xor	a
	ld	(_drw_Ln),a
_drw_gllp:
	inc	hl
	ld	a,(hl)
	or	a
	jr	z,lb_rex
	sub	#'0'
	jr	c,lb_rex
	cp	#10
	jr	nc,lb_rex

	ld	c,a
	ld	a,(_drw_Ln)
	ld	b,a
	scf
	ccf
	rlca		;x 8
	rlca
	rlca
	adc	b	;+2  = x 10
	adc	b
	adc	c
	ld	(_drw_Ln),a
	jr	_drw_gllp
lb_rex:
	pop	bc
	pop	af
	pop	hl
	ret

	.area	_XDATA

_drw_f:		.db #0
_drw_B:		.db #0
_drw_N:		.db #0
_drw_sg:	.db #0	; 0 no sign, 1="+", 2="-"
_drw_Ln:	.db #0
_drw_m:		.db #0
_drw_YX:	.dw #0
_drw_Scale:	.db #1

	.area	_CODE

__ei_halt::
	ei
	halt
	ret
