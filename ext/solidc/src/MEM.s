;---
;	MEM.H
;	Low level memory functions
;
;	(c) 1997, SOLID MSX C
;
;	SDCC port 2015
;
;---

	.area _CODE


;--- proc 	MEMCHR
;
;	char *memchr( char *adr, char c, int n )

_memchr::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix)
	ld c,7(ix)
	ld b,8(ix)
	pop ix
	
	ld	a,e
	cpir
	dec	hl
	ret z			;found
	ld	hl,#0		;not found
	ret

;--- end of proc 

;--- proc 	MOVMEM
;
;	void	memset( char *adr, char c, int n )
;

_memset::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix)
	ld c,7(ix)
	ld b,8(ix)
	pop ix
	
	ld	a,b
	or	c
	ret	z
	ld	(hl),e
	ld	e,l
	ld	d,h
	inc	de
	dec	bc
	jr	_imovmem

;--- end of proc 


;--- proc	MEMCPY
;
;	void	memcpy( char *dst, char *src, int n )
;

_memcpy::
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld d,5(ix)
	ld l,6(ix)
	ld h,7(ix)
	ld c,8(ix)
	ld b,9(ix)
	pop ix
_imovmem:
	
	ld	a,b
	or	c
	ret	z
	ldir
	ret

;--- end of proc 


;--- proc 	MEMCMP
;
;	int memcmp( char *s1, char *s2, int n )
;

_memcmp::
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld d,5(ix)
	ld l,6(ix)
	ld h,7(ix)
	ld c,8(ix)
	ld b,9(ix)
	pop ix
lb_cp0:
	ld	a,(de)
	sub	(hl)
	jr	nz,lb_cp1
	inc	hl
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,lb_cp0
	ld	h,a
	ld	l,a
	ret
lb_cp1:
	ld	hl,#1
	ret	nc
	ld	hl,#-1
	ret

;--- end of proc 

