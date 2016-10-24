;
;
;	VDPgraph2.h	- MSX2 graphics VDP functions
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

_SetScreen5::

	; Standard case from MSXDOS
	call	_vMSX
	dec	a
	ret	z
	
	ld      a,(#_VDP)
	and	#0b11110001
	or      #0b00000110		; set M3,M4 mode flags
	ld	(#_VDP),a
	call	_wrreg_0
	ld      a,(#_VDP+#1)		; enable interrupts, otherwise keyboard freezes
	or      #0b00100000
	ld	(#_VDP+#1),a
	call	_wrreg_1

	ld	a,#5	; Screen 5 MSX2
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
	
;VRAM Data (Read/Write) port 0x98
;VDP Status Registers port 0x99

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

;-----------
;	Sets palette, provide table pointer
;
_SetPalette::
        ; Sets colors by given RGB-table in HL-reg
	
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
	
_isetpalette:	
	ld	b,#0x10		; 16 colours
SPcoLoop:
	di
	ld	a,(hl)
	inc	hl
	out	(#0x99),a	; colour Nr.
	ld	a, #128+#16
	out	(#0x99),a       
	ld	a,(hl)		; red
	inc	hl
	inc	hl
	sla	a
	sla	a
	sla	a
	sla	a		; bits 4-7
	ld	c,a
	ld	a,(hl)		; blue bits 0-3
	dec	hl
	or	c
	out	(#0x9A),a
	ld	a,(hl)		; green bits 0-3
	inc	hl
	inc	hl
	out	(#0x9A),a
	ei 
	djnz	SPcoLoop
	ret
	
;-----------
;	Sets palette, provide table pointer
;
_RestorePalette::
	ld	hl, #__msx_palette
	jr	_isetpalette

	.area	_XDATA
	;	.area _DATA crashes
	
;---------------------------------------------------
;        colour  R  G  B   bright 0..7   Name
;---------------------------------------------------
__msx_palette:
	.db #0,  #0,#0,#0		;transparent
	.db #1,  #0,#0,#0		;black
	.db #2,  #1,#6,#1		;bright green
	.db #3,  #3,#7,#3		;light green
	.db #4,  #1,#1,#7		;deep blue
	.db #5,  #2,#3,#7		;bright blue
	.db #6,  #5,#1,#1		;deep red
	.db #7,  #2,#6,#7		;light blue
	.db #8,  #7,#1,#1		;bright red
	.db #9,  #7,#3,#3		;light red
	.db #10, #6,#6,#1		;bright yellow
	.db #11, #6,#6,#3		;pale yellow
	.db #12, #1,#4,#1		;deep green
	.db #13, #6,#2,#5		;purple
	.db #14, #5,#5,#5		;grey
	.db #15, #7,#7,#7		;white

	.area	_CODE

;-----
; working with memory only, no sprite collisions and other things slowing down VDP
;
	
_SetFasterVDP::
			; sprites off (bit1), VRAM quantity (bit3)- Affects how VDP performs refresh on DRAM chips
	di	
	ld      a,(#_VDP+#8)
	or	#0b00001010
	ld	(#_VDP+#8),a 
	out	(#0x99),a
	ld	a, #128+#8     
	out	(#0x99),a
	ei
	ret
	
;---------------------------------------- 2 pixel writing/reading mode	
;
; VDP write/read at address
;
_pos_byXY:		; Procedure calculates hl offset and sets VDP for writing
	di
	ld	a,d	; d=x[0..255]
	and	#254
	rra
	ld	l,a	;2px per byte 
	ld	a,e	; e=y[0..211]
	ld	de,#0
	bit	#0,a
	jr	z,lb_l2b
	ld	e,#0x80
lb_l2b:
	rra
	ld	h,a
	add	hl,de
	ei
	ret
	 
; This prepares for "pixeling",  HL contains initial address
_VDPwrite:
	xor	a
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0171	; NSTWRT Sets up the VDP for writing with full 16 bits VRAM address
	pop	ix
	ret         


_VDPdraw2pixels:		; Put 2 pixels by sending one byte with 2 colour Nr. (bits 0-3,4-7)
	out (#0x98),a		; send this sequentially
	ret

_VDPread:
	xor	a
	push	ix
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x016E	; NSETRD Sets up the VDP for reading with full 16 bits VRAM address
	pop	ix
	ret
	
_VDPget2pixels:           	; Get 2 pixels, one byte with 2 colour Nr. (bits 0-3,4-7)
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
	xor	#0xFF
	ld	l,a
	ld	h,#0
	pop	ix
	ret 
	
_keyboard_read_3::
	push	ix
	in	a,(#0xAA)
	and	#0xF0		; only change bits 0-3
	or	#3		; row 3
	out	(#0xAA),a
	in	a,(#0xA9)	; read row into A
	xor	#0xFF
	ld	l,a
	ld	h,#0
	pop	ix
	ret 

_keyboard_read_7::
	push	ix
	in	a,(#0xAA)
	and	#0xF0		; only change bits 0-3
	or	#7		; row 7
	out	(#0xAA),a
	in	a,(#0xA9)	; read row into A
	xor	#0xFF
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
				; MSX1
	ld	de, #_MSX1_err_
	ld	c, #9
	call	#5	; display "MSX1 not supported"
	ld	a,#1
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
	ld	hl,#_VDP+#8
	ld	de,#_VDP_0+#8
	ld	bc,#17
	ldir
	ret

_Restore_VDP::
	ld	bc,#0x0800
	ld	hl,#_VDP_0
	call    lb_rstVdp
	ld      bc,#0x1008
	ld      hl,#_VDP_0+#8
	call    lb_rstVdp
	
	; not sure, hangs sometimes on R#19h
	; Register 19h: 9958 ONLY -- Horizontal Scroll Control
	;ld      bc,#0x0319
	;ld      hl,#_Vdp000
	;call    lb_rstVdp
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
	

_VDP:		.dw  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
_VDP_0:		.dw  #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
_Vdp000:	.db #0,#0,#0

_curPage:	.db #0
_MSX1_err_:	.ascii "MSX1 not supported by VDPgraph2$\n"
_curHL:		.dw #0
	.area	_CODE
	
;
; Coordinate system of VRAM 
; pages and memory blocks (32kb)
;	(SCREEN 5)
; ------------------------------	  00000H
; | (0,0) 	     (255,0) |	    |
; |	    Page 0	     |	    |
; | (0,255)	   (255,255) |	    |
; ------------------------------	  08000H
; | (0,256)	   (255,256) |	    |
; |	    Page 1	     |	    |
; | (0,511)	   (255,511) |	    |
; ------------------------------	  10000H
; | (0,512)	   (255,512) |	    |
; |	    Page 2	     |	    |
; | (0,767)	   (255,767) |	    |
; ------------------------------	  18000H
; | (0,768)	   (255,768) |	    |
; |	    Page 3	     |	    |
; | (0,1023)	  (255,1023) |	    |
; ------------------------------	  1FFFFH 

;
;Set page [0..3] in screen 5.
;
_SetPage::

	ld  hl,#2
	add hl,sp
	ld a,(hl)
	ld (#_curPage),a
	
_iSetPage:
        add     a,a ;x32
        add     a,a
        add     a,a
        add     a,a
        add     a,a
        add     a,#31
        ld      (#_VDP+#2),a
        di
	out     (#0x99),a
        ld      a,#128+#2
        ei
	out     (#0x99),a
        ret

;
; AHL is 17 bit value of
; Left upper corner of each pages:
; Provide page in A to set A,HL
;
;   0 -> A=0,HL=$0000
;   1 -> A=0,HL=$8000
;   2 -> A=1,HL=$0000
;   3 -> A=1,HL=$8000
;
_getAHL:
	ld	hl,#0
	and	#1
	jr	z, lb_ahl_0
	ld	h,#0x80
lb_ahl_0:
	ret

_bumpVDP::			;Resets current page.
	call	VDPready
	ld	a,(#_curPage)
	call	_iSetPage
	ret
;
; Set VDP port $98 to start writing at address AHL (17-bit)
;	Page provided.
;
_Set_VDP_Write::           ; A(1bit),HL(16bits) input

	ld  hl,#2
	add hl,sp
	ld a,(hl)

_isetvdpwrite:
	push	hl
	call	_getAHL
	
        rlc	h
        rla
        rlc	h
        rla
        srl	h
        srl	h
        di
	out     (#0x99),a
        ld	a,#14+#128
	out     (#0x99),a
        ld	a,l
        nop
	out     (#0x99),a
        ld	a,h
        or	#64
        ei
	out     (#0x99),a
	pop	hl
        ret

;
; A dumb memory to screen write
;

_Write_Scr::

	push ix
	ld ix,#0
	add ix,sp

	ld l,4(ix)
	ld h,5(ix)
	
;
;  It's better to use BIOS #005C Block transfer to VRAM from memory
;
	push	hl
	ld	bc,#0x6A00	;256/2 * 212 lines
	ld	hl,#0
	call	_VDPwrite
	pop	hl
	ld	de,#0
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x005C	; LDIRVM 	Block transfer to VRAM from memory 

;	
;	ld	bc,#0x6A00	;256/2 * 212 lines heavy direct VDP access loop 
;lb_wr0:
;	ld	a,(hl)
;	inc	hl
;	out	(#0x98),a
;	dec	bc
;	ld	a,b
;	or	c
;	jr	nz, lb_wr0

	pop ix
	ret 

;
; Set VDP port $98 to start reading at address AHL (17-bit)
;	Page provided.
;
_Set_VDP_Read::

	ld  hl,#2
	add hl,sp
	ld a,(hl)
	call	_getAHL
	
        rlc	h
        rla
        rlc	h
        rla
        srl	h
        srl	h
        di
	out     (#0x99),a       ;set bits 15-17
	ld	a,#128+#14
	out     (#0x99),a
        ld      a,l		;set bits 0-7
        nop
	out     (#0x99),a
        ld	a,h		;set bits 8-14
        ei			; + read access
	out     (#0x99),a
        ret
	
;
; A dumb screen to memory read
;

_Read_Scr::

	push ix
	ld ix,#0
	add ix,sp

	ld l,4(ix)
	ld h,5(ix)

;
;  It's better to use BIOS #0059 Block transfer to memory from VRAM
;
	push	hl
	ld	bc,#0x6A00	;256/2 * 212 lines
	ld	hl,#0
	call	_VDPread
	pop	de
	ld	hl,#0
	.db	#0xF7	; RST 30h
	.db	#0x80
	.dw	#0x0059	; LDIRMV 	Block transfer to memory from VRAM

;	
;	ld	bc,#0x6A00	;256/2 * 212 lines heavy direct VDP access loop 
;lb_rd0:
;	in	a,(#0x98)
;	ld	(hl),a
;	inc	hl
;	dec	bc
;	ld	a,b
;	or	c
;	jr	nz, lb_rd0

	pop ix
	ret
	
VDPready:
	ld	a,#2
	di
	out	(#0x99),a          ;select status register 2
	ld	a,#128+#15
	out	(#0x99),a
	in	a,(#0x99)

	bit	#0,a
	jr	nz, VDPready	; wait
	
	rra
	xor	a
	out	(#0x99),a 
	ld	a,#128+#15
	out	(#0x99),a 
	ei
	jr	c,VDPready    ;wait till previous VDP execution is over (CE)
	ret

	
;****************************************************************
;	PSET puts pixel
;		 to use, set H, L, E, A as follows
;		 pset (x:H, y:L), color:E, logi-OP:A
;****************************************************************
;

_PSET::
	push ix
	ld ix,#0
	add ix,sp
	ld h,4(ix)
	ld l,6(ix)
	ld e,8(ix)
	ld d,10(ix)
	pop ix
_ipset:
	di
	call	VDPready

	ld	a,#36
	out	(#0x99),a
	ld	a,#128+#17
	out	(#0x99),a

	xor	a
	ld	c,#0x9b
	out	(c),h
	out	(c),a
	out	(c),l
	out	(c),a

	ld	a,#44
	out	(#0x99),a
	ld	a,#128+#17
	out	(#0x99),a

	out	(c),e
	xor	a
	out	(c),a

	ld	e,#0b01010000
	ld	a,d	; new color
	or	e
	out	(c),a
	
	call	VDPready
	
	ei
	ret

;****************************************************************
; METHOD 2   Locate AHL, then set writing, then 
;	put/get 2pixel byte
;
; Set colour of pixel.
;
; void psetXY(int X, int Y, int Colour);
;
_psetXY::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	ld a,8(ix)
	
	call	_ipsetXY
	pop ix
	ret
_ipsetXY:
	ld	b,a
	push	de
	call	_pos_byXY
	ld	(_curHL),HL
	call	_VDPread
	call	_VDPget2pixels
	pop	de
	bit	#0,d
	jr	nz,lb_pst2
	and	#0x0F
	ld	c,a
	ld	a,b
	rla
	rla
	rla
	rla
	or	c
	jr lb_pstS
lb_pst2:
	and	#0xF0
	or	a,b
lb_pstS:
	ld	c,a
	ld	hl,(_curHL)
	call	_VDPwrite
	ld	a,c		; write new colour of 2 pixels
	call	_VDPdraw2pixels
	ret

;
; Get colour of pixel.
;
; int pgetXY(int X, int Y);
;
_pgetXY::
	push ix
	ld ix,#0
	add ix,sp
	ld d,4(ix)
	ld e,6(ix)
	
	call	_ipgetXY
	pop ix
	ld	l,a
	ld	h,#0
	ret
_ipgetXY:	
	push	de
	call	_pos_byXY
	call	_VDPread
	call	_VDPget2pixels
	pop	de
	
	bit	#0,d
	jr	nz,lb_psg2
	and	#0xF0
	rra
	rra
	rra
	rra
lb_psg2:
	and	#0x0F
	ret
	
;****************************************************************
;	POINT gets pixel
;		 to use, set H, L as follows
;		 POINT ( x:H, y:L )
;		 returns:   A := COLOR CODE
;****************************************************************

_POINT::
	push ix
	ld ix,#0
	add ix,sp
	ld h,4(ix)
	ld l,6(ix)
	pop ix
_ipoint:
	di
	call	VDPready
	
	ld	a,#32
	out	(#0x99),a
	ld	a,#128+#17
	out	(#0x99),a	

	xor	a
	ld	c,#0x9b
	out	(c),h
	out	(c),a
	out	(c),l
	out	(c),a

	out	(#0x99),a
	ld	a,#128+#45
	out	(#0x99),a
	ld	a,#0b01000000
	out	(#0x99),a
	ld	a,#128+#46
	out	(#0x99),a
	
	call	VDPready
	
	ld	a,#7
	call	hmmc_Status
	push	af
	xor	a
	call	hmmc_Status
	pop	af
	
	ld	l,a
	ld	h,#0
	ei
	ret
	
;****************************************************************
; draws LINE 
;        to use, set H, L, D, E, B, A and go
;        draw LINE (H,L)-(D,E) with color B, log-op A
; H,L,D,E absolute values
;****************************************************************

_LINE::
	push ix
	ld ix,#0
	add ix,sp
	ld h,4(ix)
	ld l,6(ix)
	ld d,8(ix)
	ld e,10(ix)
	ld b,12(ix)
	ld a,14(ix)
	pop ix
_iline:
	di
	push	af		;save LOGICAL OPERATION
	push	bc		;save COLOR            
	call	VDPready

	ld	a,#36
	out	(#0x99),a
	ld	a,#128+#17
	out	(#0x99),a	;R#17 := 36
	xor	a
	ld	c,#0x9b
	out	(c),h		;X from
	out	(c),a
	out	(c),l		;Y from
	out	(c),a
 
	ld	a,h		;make DX and DIX
	sub	d
	ld	d,#0b00000100
	jr	nc,gLINE1
	ld	d,#0b00000000
	neg
gLINE1:
	ld	h,a 		;H := DX , D := DIX
	ld	a,l		;make DY and DIY
	sub	e
	ld	e,#0b00001000
	jr	nc,gLINE2
	ld	e,#0b00000000
	neg
gLINE2:
	ld	l,a		;L := DY , E := DIY
	cp	h		;make Maj and Min
	jr	c,gLINE3
	xor	a
	out	(c),l		;long side
	out	(c),a
	out	(c),h		;short side
	out	(c),a
	ld	a,#0b00000001	;MAJ := 1
	jr	gLINE4
gLINE3:
	xor	a
	out	(c),h		;NX
	out	(c),a
	out	(c),l		;NY
	out	(c),a
	ld	a,#0b00000000	;MAJ := 0
gLINE4:
	or	d
	or	e		;A := DIX , DIY , MAJ
	pop	hl		;H := COLOR
	out	(c),h
	out	(c),a
	pop	af         	;A := LOGICAL OPERATION
	or	#0b01110000
	out	(c),a
	ld	a,#0x8F
	out	(c),a
         
	call	VDPready
	ei
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

	call	VDPready
	
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
	
	call	VDPready
	ld	a,(#_rect_fill)
	or	a
	ret	z
			; fill rectangle with colour
lb_rcLp:	
	ld	a,h
	sub	d
	jr	z, lb_rcOK
	jr	nc,lb_rcm
	inc	h
	inc	h
lb_rcm:
	dec	h
	push	de
	ld	d,h
	call	lb_rctl
	pop	de
	jr	lb_rcLp
lb_rcOK:
	call	VDPready
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

	.area	_CODE
;---------------------------
; Paints from the point (x:H, y:L), color:E, border color:D
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
	ld d,10(ix)
	pop ix

	call	VDPready
	
		; this is way to limit stack depth, it is better then dumb crash
_ptAgain:	
	ld	bc, #0x2000	; calculate depth, limit
	call	_paintRR
	
	ld	hl,(#_lpaintHL)
	ld	a,b
	or	c
	jr	z,_ptAgain	; if bc==0 then try paint at last position
	call	VDPready
	ret
	
_paintRR:
	ld	a,e
	push	hl
	push	de
	push	bc
	ex	de,hl		; de = X,Y
	call	_ipsetXY
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
	cp	#211
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
	call	_ipgetXY
	pop	bc
	pop	de
	pop	hl
	cp	d
	jr	z,lb_rbc
	cp	e
	jr	z,lb_rbc
	jp	_paintRR
lb_rbc:
	inc	bc
	ret
		
;****************************************************************
; HMMC (High speed move CPU to VRAM)
; Screen size 256x212 dots, each byte is colour Nr. for 2-pixels 
;
; Copies data from memory to block in VRAM
; The same as in basic COPY file.pic TO (x,y)-(x+D-1,y+E-1)
;
; RAM [IX] => VRAM (H,L)-(D,E)
;
; set ix = memory address of data to write to VRAM
; set h,l,d,e for rectangle to put in
; D,E mod 2 = 0 !
;****************************************************************

_HMMC::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	push hl
	ld h,6(ix)
	ld l,8(ix)	
	ld d,10(ix)
	ld e,12(ix)
	pop ix

	di      
	xor	a
	call	hmmc_wait_VDP
	
	ld	a,#36	;command register R#36
	out	(#0x99),a
	ld	a,#128+#17	;VDP(17)<=36
	out	(#0x99),a
	xor	a
	ld	c,#0x9b
	out	(c),h		;X
	out	(c),a
	out	(c),l		;Y
	out	(c),a
	out	(c),d		;DX in dots
	out	(c),a		;
	out	(c),e		;DY in dots
	out	(c),a		;
            
	ld	h,(ix)		;first byte of data
	out	(c),h       

	out	(c),a		;DIX and DIY = 0     
	ld	a,#0b11110000
	out	(c),a		; command to do it
	ld	a,#128+#44
	out	(#0x99),a
	ld	a,#128+#17
	out	(#0x99),a	; VDP(17)<=44
hmmc_Loop:
	ld	a,#2
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	in	a,(#0x99)
	ld	b,a
	xor	a
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	ld	a,b
	bit	#7,a		; TR? transferring?
	jr	z, hmmc_Loop
	bit	#0,a		; CE? is over?
	jr	z, hmmc_exit                       
	inc	ix
	ld	a,(ix)
	out	(#0x9b),a
	jr	hmmc_Loop                                                      
hmmc_exit:
	xor	a
	call	hmmc_Status
	ei
	pop	ix
	ret
	
hmmc_Status:
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	in	a,(#0x99)
	push	af
	xor	a
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	pop	af
	ret
	
hmmc_wait_VDP:
	ld	a,#2
	call	hmmc_Status
	and	#1
	jr	nz,hmmc_wait_VDP
	xor	a
	call	hmmc_Status
	ret


;****************************************************************
; HMCM (High speed move VRAM to CPU)
; Screen size 256x212 dots, each byte is colour Nr. for 2-pixels 
;
; Copies data from memory block in VRAM to RAM memory address
; The same as in basic SAVE (H,L)-(D-1,E-1) TO file.pic
;
; VRAM (H,L)-(D,E) => RAM [IX]
; VRAM (D,E)-(H,L) => RAM [IX]	; backwards scanned
;
; set ix = memory address of data to write to RAM
; set h,l,d,e for rectangle
; D,E mod 2 = 0 !
;****************************************************************

_HMCM::
	push ix
	ld ix,#0
	add ix,sp
	ld l,12(ix)
	ld h,13(ix)
	push hl
	ld h,4(ix)
	ld l,6(ix)	
	ld d,8(ix)
	ld e,10(ix)
	pop ix

	di      
	xor	a
	call	hmcm_wait_VDP
	
	ld	a,#32	;command register R#32
	out	(#0x99),a
	ld	a,#128+#17	;VDP(17)<=32
	out	(#0x99),a
	xor	a
	ld	c,#0x9b
	out	(c),h		;SX
	out	(c),a
	out	(c),l		;SY
	out	(c),a
	
	out	(c),a		;dummy 
	out	(c),a		;dummy 
	out	(c),a		;dummy 
	out	(c),a		;dummy

	call	DIX_DIY
	
	out	(c),h		;NX in dots
	out	(c),a		;
	out	(c),l		;NY in dots
	out	(c),a		;
            
	ld	a,(ix)		;first byte of data
	out	(c),a		;dummy
	ld	a,d
	or	e
	out	(c),a		;DIX and DIY
	
	ld	a,#7		;clear TR status
	call	hmcm_Status

	ld	a,#0b10100000	;LMCM command 
	out	(c),a

hmcm_Loop:
	ld	a,#2
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	in	a,(#0x99)
	bit	#0,a		; CE? is over?
	jr	z, hmcm_exit
	bit	#7,a		; TR? transferring?
	jr	z, hmcm_Loop

	; read 2 pixels
	ld	a,#7		; 1px
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	in	a,(#0x99)	
	rla
	rla
	rla
	rla
	ld	b,a

	ld	a,#7		; 2nd px
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	in	a,(#0x99)
	or	b
	
	ld	(ix),a
	inc	ix
	
	jr	hmcm_Loop                                                      
hmcm_exit:
	xor	a
	call	hmcm_Status
	ei
	pop	ix
	ret
	
hmcm_Status:
	out	(#0x99),a
	ld	a,#0x8f
	out	(#0x99),a
	in	a,(#0x99)
	ret
	
hmcm_wait_VDP:
	ld	a,#2
	call	hmcm_Status
	and	#1
	jr	nz,hmcm_wait_VDP
	xor	a
	call	hmcm_Status
	ret

;
;	Scanning from top to right down (0), or from bottom to left up
;
DIX_DIY:
	ld	a,h		;make NX and DIX 
	sub	d
	ld	d,#0b00000100
	jr	nc,lb_dxy1
	ld	d,#0b00000000
	neg
lb_dxy1:
	ld	h,a		;H := NX , D := DIX
 	ld	a,l
	sub	e
	ld	e,#0b00001000
	jr	nc,lb_dxy2
	ld	e,#0b00000000
	neg
lb_dxy2:
	ld	l,a		;L := NY , E := DIY
	xor	a
	ret
	
;****************************************************************
;  LMMM (High speed Logical move VRAM to VRAM)
;        to use, set H, L, D, E, B, C, A-logical operation and go
;        VRAM (H,L)-(D,E) ---> VRAM (B,C)
;        VRAM (D,E)-(H,L) ---> VRAM (B,C)	;backwards scanned
; byte DIX,DIY=0, explained:
; The 0 copies the block starting from the upper left, the 1 from right/bottom.
; what's the difference? when copying overlapping source/destination
; (a scroller for example)
; when scrolling from right to left DIX/DIY can both be 0
;  but copying from left to right DIX must be 1. just figure it out...
; Then give coord.positive from right upper corner to left.
;****************************************************************

_LMMM::
	push ix
	ld ix,#0
	add ix,sp

	ld h,4(ix)
	ld l,6(ix)	
	ld d,8(ix)
	ld e,10(ix)
	ld b,12(ix)
	ld c,14(ix)
	ld a,16(ix)
	
	di
	push	af
	call	VDPready
	ld	a,#32
	out	(#0x99),a
	ld	a,#128+#17
	out	(#0x99),a	;R#17 := 32

	push	de
	push	bc
	xor	a
	ld	c,#0x9b
	out	(c),h		;X from
	out	(c),a
	out	(c),l		;Y from
	out	(c),a
	pop	de		; de=bc	
	out	(c),d		;X to
	out	(c),a
	out	(c),e 		;Y to
	out	(c),a
	pop	de		; de=de
	
	call	DIX_DIY
		
	out	(c),h		;DX in dots
	out	(c),a
	out	(c),l		;DY in dots
	out	(c),a
	out	(c),a		;dummy
	
	ld	a,d
	or	e
	out	(c),a		;DIX and DIY
	
	pop	af
	or	#0b10010000	;LMMM command or with LOGICAL
	
	out	(c),a		;do it
	call	VDPready
	ei
	pop	ix
	ret
           
;****************************************************************
;  fLMMM (Far high speed Logical move VRAM to VRAM)
;   for not simplest case, structure provided
;****************************************************************

_fLMMM::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
	
	di
	call	VDPready
	ld	a,#32
	out	(#0x99),a
	ld	a,#128+#17
	out	(#0x99),a	;R#17 := 32
			
	ld	bc,#0x0E9b	; c=#0x9b
				; b=6x2bytes + dummy + DI...
	otir			; X,Y,X2,Y2,DX,DY,DIY,DIX 
	 
	ld	a,(hl)		; Logical, operation
	bit	#7,a
	jr	nz, lb_flq
	or	#0b10010000	;LMMM command
lb_flq:
	out	(c),a		; do it, VDP!
	call	VDPready

	ei
	ret


;--------------------------------------------
;	S P R I T E S
;--------------------------------------------

;
;Enable the sprites.
;
_Sprites_On::
	ld	a,(#_VDP+#8)
	and	#0b11111101
	ld	(#_VDP+#8),a
_wrreg_8:
	di
	out	(#0x99),a
	ld	a,#128+#8
	ei
	out     (#0x99),a
	ret

;
;Disable the sprites.
;
_Sprites_Off::
	ld	a,(#_VDP+#8)
	or      #0b00000010
	ld	(#_VDP+#8),a
	jr	_wrreg_8
	ret

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

			; BIOS command to write to VRAM
LDIRVM			.equ	#0x005c

;  VRAM default memory map of sprites
; -----------------------------------------------------------------------
; | 0x7400  - 0x75FF 	512 bytes = 32 sprites * 16-lines of colours	|
; |									|
; | 0x7600  - 0x767F 	128 bytes = 32 sprites * 4 bytes of attributes	|
; |									|
; | +384 bytes			0x7680  - 0x769F	colour palette	|
; | 				0x76A0  - 0x77FF			|
; |									|
; | 0x7800  - 0x7FFF 	2Kb bytes = 256 patterns * 8 bytes of points	|
; -----------------------------------------------------------------------

SPRITES_PATTERN		.equ	#0x7800
SPRITES_ATTRIBS		.equ	#0x7600
SPRITES_COLOURS		.equ	#0x7400

;--------------------------------------------------------
; Define new pattern for sprites
;
;	Number of pattern 0..255	(2Kb for all pattern data)
;	Address of data to write to sprite VRAM pattern table (8 or 16 bytes)
;--------------------------------------------------------

_SpritePattern::
	xor	a
	ld	(#_spr_bct),a
	ld	hl, #SPRITES_PATTERN
	jr	SprWrTbBg
	
;--------------------------------------------------------
; Define new colours for sprites
;
;	Number of sprite 0..31
;	Address of data to write to sprite VRAM colour table
;--------------------------------------------------------
_SpriteColours::
	ld	a,#1
	ld	(#_spr_bct),a
	ld	hl, #SPRITES_COLOURS
	
SprWrTbBg:
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
		; 8 dummies for colours of lines of 8x8 sprite
	ld	a,(#_spr_bct)
	or	a
	jr	z, lb_skpdm
	ld	a,(#_spr_16)
	or	a
	jr	nz, lb_skpdm
	ld	b,#8
lb_lpdm:
	out	(c),a
	djnz	lb_lpdm
	
lb_skpdm:
	xor	a
	ld	(#_spr_bct),a
	
	ld	hl,#0
	call	_VDPwrite
	ei
	ret
		
	; positions HL to sprite number in reg-e
Spr_locTb:
	ld	bc,#16
	ld	a,(#_spr_bct)
	or	a
	jr	nz,Spr_TbSpk		; 16 bytes colours
	
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
;	Y [0..211]
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

_spr_bct:	.db #0
_spr_thb:	.dw #0		
_spr_16:	.db #0		; keep value here, default 8x8
_spr_atrb:	.db #0,#0,#0,#0x0F
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

	call	VDPready
	
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
	ld	c,#211
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
