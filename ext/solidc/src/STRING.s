;---
;	STRING.H
;	Low level string functions
;
;	(c) 1997, SOLID MSX C
;
;	SDCC port 2015
;
;---

	.area _CODE

;--- proc  STRCPY
;
;	void	strcpy( char *dst, char *src )
;
_strcpy::
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld d,5(ix)
	ld l,6(ix)
	ld h,7(ix)
	pop ix
lb_cy:
	ld	a,(hl)
	ldi
	or	a
	jr	nz,lb_cy
	ret
	
	
;--- end of proc

;--- proc  STRNCPY
;
;	void	strncpy( char *dst, char *src, int n )
;
_strncpy::
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
	
	ld	a,b
	or	c
	jr	z,lb_p5
	
lb_p2:	ld	a,(hl)
	ldi
	jp	pe,lb_p4
	jr	lb_p5
lb_p4:
	or	a
	jr	nz,lb_p2
lb_p5:
	xor	a
	ld	(de),a
	ret

	
;--- end of proc 

;--- proc  STRLEN
;
;	int	strlen( char *adr )
;
_strlen::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
	
	xor	a
	ld	b,a
	ld	c,a
	push	hl
	cpir
	pop	de
	scf
	sbc	hl,de
	ret
	
;--- end of proc 
	
;--- proc  STRCAT
;
;	void	strcat( char *dst, char *src )
;
_strcat::
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld d,5(ix)
	ld l,6(ix)
	ld h,7(ix)
	pop ix
	
	ex	de,hl
	ld	bc,#0
	xor	a
	cpir
	ex	de,hl
	dec	de
lb_ct1:
	ld	a,(hl)
	ldi
	or	a
	jr	nz,lb_ct1
	ret
	
;--- end of proc 

;--- proc  STRNCAT
;
;	void	strncat( char *dst, char *src, int n )
;
_strncat::

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
	push bc
	ex	de,hl	
	xor	a
	ld	bc,#0
	cpir
	ex	de,hl
	dec	de
	pop bc
	
	ld	a,b
	or	c
	jr	z,lb_c5
	
lb_c2:	ld	a,(hl)
	ldi
	jp	pe,lb_c4
	jr	lb_c5
lb_c4:
	or	a
	jr	nz,lb_c2
lb_c5:
	xor	a
	ld	(de),a
	ret
	
;--- end of proc 

;--- proc  STRCMP
;
;	int	strcmp( char *s1, char *s2 )
;
_strcmp::
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld d,5(ix)
	ld l,6(ix)
	ld h,7(ix)
	pop ix
lb_cp6:
	ld	a,(de)
	sub	(hl)
        jr	nz,lb_cp8
	inc	de
	inc	hl
	ld	a,(de)
	or	a
	jr	nz,lb_cp6
	ld	hl,#0
	ret
lb_cp8:
	ld	hl,#1
	ret	nc
	ld	hl,#-1
	ret 
	
;--- end of proc

;--- proc  STRNCMP
;
;	int	strncmp( char *s1, char *s2, int n )
;

_strncmp::
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
lb_n1:
	ld	a,(de)
	sub	(hl)
        jr	nz,lb_n3
	ld	a,(de)
	or	a
	jr	z,lb_n2
	inc	de
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,lb_n1
lb_n2:
	ld	hl,#0
	ret
lb_n3:
	ld	hl,#1
	ret	nc
	ld	hl,#-1
	ret 
	
;--- end of proc  

;--- proc  STRCHR
;
;	int	strchr( char *adr, char c )
;

_strchr::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix)
	pop ix
	ld	bc, #0
lb_c8:
	ld	a,(hl)
	cp	e
	jr	z, lb_c9
	inc	hl
	inc	bc
	or	a
	jr	nz, lb_c8
	ld	bc, #-1
lb_c9:
	ld	h,b
	ld	l,c
	ret
	
	
;--- end of proc 

;--- proc  STRPBRK
;
;	int	strpbrk( char *s1, char *s2 )
;

_strpbrk::
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld d,5(ix)
	ld l,6(ix)
	ld h,7(ix)
	ld (lb_bHL), hl
	pop ix
	
	ld	a,(hl)
	or	a
	ld	hl, #0
	ret	z
lb_b1:
	ld	a,(de)
	or	a
	jr	z, lb_b2
	push	hl
	ld	hl, (lb_bHL)
	ld	c,a
	call	_inran
	pop	hl
	ret	nz
	inc	de
	inc	hl
	jr	lb_b1
lb_b2:
	ld	hl, #-1
	ret

lb_bHL:	.db #0,#0

_inran:
	ld	a,(hl)
	or	a
	ret	z
	cp	c
	inc	hl
	jr	nz,_inran
	or	#0xff
	ret

;--- end of proc

;--- proc  STRRCHR
;
;	int	strrchr( char *adr, char c )
;
_strrchr::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix)
	pop ix
	
	ld	de, #-1
	ld	bc, #0
lb_cA:
	ld	a,(hl)
	cp	6(ix)		; compare with char
	jr	nz, lb_cB
	ld	d,b
	ld	e,c
lb_cB:
	inc	hl
	inc	bc
	or	a
	jr	nz, lb_cA
	ex	de, hl
	ret
	
;--- end of proc 

;--- proc  STRLWR
;
;	void	strlwr( char *adr )
;
_strlwr::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
lb_sl1:
	ld	a,(hl)
	or	a
	jr	z,lb_sl2
	call	_to_lower
	ld	(hl),a
	inc	hl
	jr	lb_sl1
lb_sl2:
	ret

_to_lower:
	cp	#'A'
	ret	c
	cp	#'['
	ret	nc
	add	a,#' '
	ret

;--- end of proc 

;--- proc  STRUPR
;
;	void	strupr( char *adr )
;
_strupr::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
lb_sl3:
	ld	a,(hl)
	or	a
	jr	z,lb_sl4
	call	_to_upper
	ld	(hl),a
	inc	hl
	jr	lb_sl3
lb_sl4:
	ret

_to_upper:
	cp	#'a'
	ret	c
	cp	#'{'
	ret	nc
	sub	#' '
	ret
	
;--- end of proc 
	
;--- proc  STRSTR
;
;	int	strstr( char *s1, char *s2 )
;
_strstr::
	
	push ix
	ld ix,#0
	add ix,sp
	ld e,4(ix)
	ld d,5(ix)
	ld l,6(ix)
	ld h,7(ix)
	ld	(lb_qHL),hl
	pop ix

	ld	a,(hl)
	or	a
	ld	hl, #0
	ret	z
lb_q1:
	ld	a,(de)
	or	a
	jr	z, lb_q2
	push	hl
	ld	hl,(lb_qHL)
	push	de
	call	_striseq
	pop	de
	pop	hl
	ret	z
	inc	de
	inc	hl
	jr	lb_q1
lb_q2:
	ld	hl, #-1
	ret
	
lb_qHL:	.db #0,#0

_striseq:

lb_q4:
	ld	a,(de)
	sub	(hl)
        jr	nz, lb_q9
	inc	de
	inc	hl
	ld	a,(de)
	or	a
	jr	nz,lb_q4
	ld	a,(hl)
	or	a
	ret
lb_q9:
	ld	a,(hl)
	or	a
	ret

;--- end of proc 

;--- proc  STRLTRIM
;
;	void	strltrim( char *adr )
;
_strltrim::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	pop ix
	
	ld	a,(hl)
	or	a
	ret	z
	cp	#' '
	ret	nz
	push	hl
	pop	de
lb_l0:
	ld	a,(hl)
	or	a
	jr	z, lb_l1
	cp	#' '
	jr	nz, lb_l1
	inc	hl
	jr	lb_l0
lb_l1:
	ld	a,(hl)
	ldi
	or	a
	jr	nz, lb_l1
	ret
	
;--- end of proc

;--- proc  STRRTRIM
;
;	void	strrtrim( char *adr )
;
_strrtrim::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld	(lb_lHL),hl
	pop ix
		
	ld	a, #' '
lb_l3:
	cpi	
	jr	z,lb_l3
	dec	hl
	
	ld	a, (hl)
	or	a
	jr	nz, lb_l4
	
	ld	hl,(lb_lHL)
	xor	a
	ld	(hl),a
	ret
lb_l4:
	xor	a
	cpir
	dec	hl
lb_l5:	
	dec	hl
	ld	a,(hl)
	cp	#' '
	ret	nz
	xor	a
	ld	(hl),a
	jr	lb_l5

lb_lHL:	.db #0,#0

;--- end of proc

;--- proc  STRTRPLCHR
;
;	void	strreplchr( char *adr, char c, char nc )
;
_strreplchr::
	push ix
	ld ix,#0
	add ix,sp
	ld l,4(ix)
	ld h,5(ix)
	ld e,6(ix)
	ld d,7(ix)
	pop ix
lb_r1:
	ld	a,(hl)
	or	a
	ret	z
	cp	e
	jr	nz, lb_r2
	ld	(hl),d
lb_r2:
	inc	hl
	jr 	lb_r1
	
;--- end of proc	
