;
;	CTYPE.H
;	general types definition for ASCII or SOLID C
;
;	(c) 1995, SOLID MSX C
;
;	SDCC port 2015
;


	.area _DATA
;
;	table for ctype functions
;
_ctype::

	.DB	#1,#1,#1,#1,#1,#1,#1,#1,#1,#3,#3,#3,#3,#3,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1,#1
	.DB	#1,#2,#8,#8,#8,#8,#8,#8,#8,#8,#8,#8,#8,#8,#8,#8,#8,#20,#20,#20,#20,#20,#20,#20,#20,#20,#20,#8,#8,#8,#8,#8
	.DB	#8,#8,#48,#48,#48,#48,#48,#48,#32,#32,#32,#32,#32,#32,#32,#32,#32,#32,#32,#32,#32,#32
	.DB	#32,#32,#32,#32,#32,#32,#8,#8,#8,#8,#8,#8,#80,#80,#80,#80,#80,#80,#64,#64,#64,#64,#64
	.DB	#64,#64,#64,#64,#64,#64,#64,#64,#64,#64,#64,#64,#64,#64,#64,#8,#8,#8,#8,#1,#0,#0,#0,#0
	.DB	#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
	.DB	#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
	.DB	#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
	.DB	#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0

	.area _CODE

;--- proc 	TOLOWER
;
;	char	tolower(char ch)
;
_tolower::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)
	
	cp	#'A'
	jr	c, lb_q1
	cp	#'['
	jr	nc,  lb_q1
	add	a,#' '
	jr	lb_q2
lb_q1:
	ld	a,(hl)
lb_q2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 


;--- proc 	TOUPPER
;
;	char	toupper(char ch)
;
_toupper::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)
	
	cp	#'a'
	jr	c, lb_z1
	cp	#'{'
	jr	nc, lb_z1
	sub	#' '
	ld	l,a
	ld	h,#0
	jr	lb_z2
lb_z1:
	ld	a,(hl)
lb_z2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 


;--- proc 	ISDIGIT
;
;	char	isdigit(char ch)
;
_isdigit::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	cp	#'0'
	jr	c,lb_i1
	cp	#'9'+1
	jr	nc,lb_i1
	ld	a,#1
	jr	lb_i2
lb_i1:
	xor	a
lb_i2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 


;--- proc 	ISUPPER
;
;	char	isupper(char ch)
;
_isupper::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	cp	#'A'
	jr	c,lb_u1
	cp	#'Z'+1
	jr	nc,lb_u1
	ld	a,#1
	jr	lb_u2
lb_u1:
	xor	a
lb_u2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 


;--- proc 	ISLOWER
;
;	char	islower(char ch)
;
_islower::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	cp	#'a'
	jr	c,lb_w1
	cp	#'z'+1
	jr	nc,lb_w1
	ld	a,#1
	jr	lb_w2
lb_w1:
	xor	a
lb_w2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 

	
;--- proc 	ISASCII
;
;	char	isascii(char ch)
;
_isascii::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	cp	#13
	jr	z, lb_c1
	cp	#10
	jr	z, lb_c1
	cp	#' '
	jr	c, lb_c1
	cp	#0x7F
	jr	nc, lb_c1
	ld	a,#1
	jr	lb_c2
lb_c1:
	xor	a
lb_c2:
	ld	l,a
	ld	h,#0
	ret


;--- end of proc 


;--- proc 	ISALNUM
;
;	char	isalnum(char ch)
;
_isalnum::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#4+#32+64
	and	(hl)
	jr	z,lb_l2
	ld	a,#1
lb_l2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 



;--- proc 	ISXDIGIT
;
;	char	isxdigit(char c)
;
_isxdigit::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#16
	and	(hl)	
	jr	z,lb_d2
	ld	a,#1
lb_d2:
	ld	l,a
	ld	h,#0
	ret
	
;--- end of proc 



;--- proc 	ISSPACE
;
;	char	isspace(char ch)
;
_isspace::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#2
	and	(hl)
	rra
	ld	l,a
	ld	h,#0	
	ret

;--- end of proc 

;--- proc 	ISCNTRL
;
;	char	iscntrl(char ch)
;
_iscntrl::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#1
	and	(hl)
	ld	l,a
	ld	h,#0	
	ret

;--- end of proc 


;--- proc 	ISPUNC
;
;	char	ispunct(char ch)
;
_ispunct::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#8
	and	(hl)
	rra
	rra
	rra
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 

;--- proc 	ISALPHA
;
;	char	isalpha(char ch)
;
_isalpha::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#32+#64
	and	(hl)
	jr	z,lb_a2
	ld	a,#1
lb_a2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 

;--- proc 	ISGRAPH
;
;	char	isgraph(char ch)
;
_isgraph::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#0xFC
	and	(hl)
	jr	z,lb_g2
	ld	a,#1
lb_g2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc 


;--- proc 	ISPRINT
;
;	char	isprint(char ch)
;
_isprint::
	ld	hl, #2
	add	hl, sp
	ld	a,(hl)	
	
	ld	l,a
	ld	h,#0
	ld	de,#_ctype
	add	hl,de
	ld	a,#0xFE
	and	(hl)	
	jr	z,lb_p2
	ld	a,#1
lb_p2:
	ld	l,a
	ld	h,#0
	ret

;--- end of proc
