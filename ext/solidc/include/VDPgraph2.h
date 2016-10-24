/*
*	VDPgraph2.h	- MSX2 graphics VDP functions. Not for MSX1.
*
*	Compile on SDCC for MSX
*
*	This works on MSXDOS, built above, not BASIC ROM, sorry.
*
*	MSX2 has +video memory VRAM the same size as memory RAM,
*	so, hold image data in VRAMs pages 1,2,3 as much as possible.
*	There are VDP built in RAM<->VRAM fast data transfer functions.
*	Games do this way by managing rectangles of pre-prepared pixels in VRAMs/RAMs memory.
*	"Aleste" does scrolling by setting visible screen area in R#23 (and R#18 for horiz.scroll)
*	This library does not change the default mapping of addresses. Good games are asm-written.
*	The functions in this library provide fast copying of VRAM blocks with logical operation.
*	VRAM and VDP of YAMAHA is what MSX2 was made for!
*
*	SCREEN 5 mode resolution 256 pixels x 212 lines x 16 colours (32kB for screen)
*	----------------------------------------------------------------------------
*	| SCREEN 5		256 (horizontal) x 212 (vertical) dots x	   |
*	|			16 colours can be displayed at the same time	   |
*	|			each of 16 colours can be selected from 512 colours|
*	| Command:		high speed graphic by VDP command available	   |
*	| Memory requirements:	32kB for screen - 6A00H bytes			   |
*	|			  (4 bits x 256 x 212)				   |
*	| BASIC:		Then compile with .ORG xxxx 			   |
*	---------------------------------------------------------------------------- 
*	
*/

extern	int	vMSX( void );		/* 1-MSX1 bad, 2-MSX2 good */
extern	void	Save_VDP( void );	/* Save VDP on start-up */
extern	void	Restore_VDP( void );	/* Restore VDP on exit, be correct! */
extern	void	SetScreen5( void );	/* SCREEN 5 (256x212 x 16colours) */
extern	void	SetScreen0( void );	/* SCREEN 0 when returning back */
extern	void	ClearScreen( void );	/* Clears screen */
extern	void	DisableScreen( void );	/* Disables output to screen, "freezes display" as it is */
extern	void	EnableScreen( void );	/* Enables output to screen, SPRITES, display is updated */
			/* Sets foreground,background,border colour by number 0..15 */
extern	void	SetColors( int ForeCol, int BackgrCol, int BorderCol );
extern	void	SetBorderColor( int colour );	/* Sets background colour by number 0..15 */

	/* Increases VDP speed by disabling sprites and other things
	slowing down VDP, intended when using high speed RAM-VRAM copy functions */
extern	void	SetFasterVDP( void );
extern	void	SetPage( int page );	/* Sets active VDP page 0..3 for Screen 5 */

	/* Prints string on graphics screen at position X=[0..255],Y=[0..211]
		String ends with 0 */
extern	void	PutText( int X, int Y,  char *str );		

	/* Whole screen RAM <=> VRAM dumb copy (0x6A00 bytes) */
	/* Writes screen from RAM memory address to VRAM, very dumb one time way, use HMMM! */
extern	void	Write_Scr( unsigned int addr_from );	
	/* Reads screen from VRAM to memory address, very dumb one time way, use HMMM! */
extern	void	Read_Scr( unsigned int addr_to );

	/* Palette */
typedef struct {
	unsigned char colour;	// colour number 0..15
	unsigned char R;	// 0..7	red brightness
	unsigned char G;	// 0..7	green brightness
	unsigned char B;	// 0..7	blue brightness
} ColRGB;
typedef struct { ColRGB rgb[16]; } Palette;
// Use tools as bmp2msx software (http://www5d.biglobe.ne.jp/~hra/software/)
//  to convert modern pictures to data files.

	/* Set colours defined in given table. */
extern	void	SetPalette (Palette *palette);
extern	void	RestorePalette ();	/* Sets default MSX palette */

extern	int	WaitForKey( void );	/* Wait for key-press, returns key code */
extern	void	ClearKeyBuffer( void );	/* Clear key buffer */
extern	int	Inkey( void );		/* Checks key-press, returns key code, otherwise 0 */

// for keyboard_read, keys of 8th line, see documentation on http://map.grauw.nl/articles/keymatrix.php
#define  KB_RIGHT  0x80
#define  KB_DOWN   0x40
#define  KB_UP     0x20
#define  KB_LEFT   0x10
#define  KB_DEL    0x08
#define  KB_INS    0x04
#define  KB_HOME   0x02
#define  KB_SPACE  0x01

//row 3
#define  KB_E      0x04 
#define  KB_D      0x02
#define  KB_H      0x20 
#define  KB_J      0x80 
#define  KB_F      0x08


//row 7
#define KB_ESC     0x04

	/* verifies MSX keyboard status by ports 0xAA,0xA9 */
extern	int	keyboard_read( void );

//row 3 (Felipe)
extern	int	keyboard_read_3( void );

//row 7 (Felipe)
extern	int	keyboard_read_7( void );

extern	void	_ei_halt( void );	/* EI+HALT to make delays */
/*
	Logical operations (OP):
	DC - destination colour already for pixel,
	SC - source colour, we want to put pixel
*/
#define	LOGICAL_IMP	0	// DC := SC	assign, set new colour
#define	LOGICAL_AND	1	// DC &= SC	assign with AND
#define	LOGICAL_OR	2	// DC |= SC	assign with OR
#define	LOGICAL_XOR	3	// DC ^= SC	assign with XOR
#define	LOGICAL_NOT	4	// DC = !SC	assign with NOT
	// if transparent SC==0, then do not assign 
#define	LOGICAL_TIMP	8	// if SC>0 then IMP
#define	LOGICAL_TAND	9	// if SC>0 then AND
#define	LOGICAL_TOR	10	// if SC>0 then OR
#define	LOGICAL_TXOR	11	// if SC>0 then XOR
#define	LOGICAL_TNOT	12	// if SC>0 then NOT

// fill logical for rectangle and circle
#define	FILL_ALL	0xFF

// Define colours
#define TRANSPARENT    0x00
#define BLACK          0x01
#define MEDIUM_GREEN   0x02
#define LIGHT_GREEN    0x03
#define DARK_BLUE      0x04
#define LIGHT_BLUE     0x05
#define DARK_RED       0x06
#define CYAN           0x07
#define MEDIUM_RED     0x08
#define LIGHT_RED      0x09
#define DARK_YELLOW    0x0A
#define LIGHT_YELLOW   0x0B
#define DARK_GREEN     0x0C
#define MAGENTA        0x0D
#define GRAY           0x0E
#define WHITE          0x0F 

	/* PAGE 0 operations for X=0..255,Y=0..211
	do not use for outside regions (16-bit AHL), then use smart fLMMM */
		
		/* puts pixel in (X,Y), logical OP=0 (just copy) */
extern	void	PSET( int X,  int Y,  int colour, int OP );	// sends data to VDP chip directly
extern	void	psetXY( int X,  int Y,  int colour );		// method 2 by rst 30h, writes in VRAM

		/* gets colour 0..15 of pixel at (X,Y)  */
extern	int	POINT( int X,  int Y );
extern	int	pgetXY( int X,  int Y );		// method 2 by rst 30h

		/* draws line (X,Y)-(X2,Y2), with logical operation*/
extern	void	LINE( int X1,  int Y1, int X2,  int Y2, int colour, int OP );
		/* draws rectangle (X,Y)-(X2,Y2), with logical operation,
		fills if OP is FILL_ALL */
extern	void	RECT( int X1, int Y1, int X2, int Y2, int colour, int OP );

/* Paint for small regions. Split them if large.
	It is not the BASIC-subROM paint! Kind of bugPaint.
	Requires large stack of memory, slower than any image processing. */
extern	void	PAINT( int X, int Y, int colour, int border_colour );

	/* Remake of BASICs "draw" with original commands (except A,X) syntax. */
extern	void	DRAW( char *drawcommands );


	/* Fast RAM <=> VRAM operations */
	
	/* High speed copy from RAM buffer to VRAM (size = DX*DY), X=0..255,Y=0..211 */
extern	void HMMC( void *pixeldatas, int X, int Y, int DX, int DY );

	/* High speed rectangle (X1,Y1)-(X2,Y2) copying from VRAM
		to RAM buffer, no logical feature */
extern	void HMCM( int X1, int Y1, int X2, int Y2, void *tobuffer );

	/* High speed copy with logical OP from VRAM to VRAM at (Xt,Yt) position */
extern	void LMMM( int X, int Y, int DX, int DY, int Xt, int Yt, int OP );

/*
	High speed far copy with logical OP from VRAM to VRAM

	To use all 128Kb VRAM, use (0,0)-(255,1023) coordinates and function fLMMM
	Visible is memory block of active page. Hide image parts outside.
	
; Coordinate system of VRAM 
; pages and memory blocks (32kb)
;	(SCREEN 5)
; ------------------------------	  00000H
; | (0,0) 	     (255,0) |	    |
; |	    Page 0	     |	    |
; | (0,255)	   (255,255) |	    |    Sprites reside 7400 - 7FFF
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

When using fLMMM then we work on coordinates level, not addressing.
fHMMM copies VRAM rectangle(X,Y)-(X+DX,X+DY) TO VRAM (X2,Y2)

----------------------------------------------------------
| Command name | Destination | Source | Units | Mnemonic |
----------------------------------------------------------
|	       |    VRAM     |	CPU   | bytes |   HMMC	 |
| High speed   |    VRAM     |	VRAM  | bytes |   YMMM	 |
| move	       |    VRAM     |	VRAM  | bytes |   HMMM	 |
|	       |    VRAM     |	VDP   | bytes |   HMMV	 |
----------------------------------------------------------
|	       |    VRAM     |	CPU   | dots  |   LMMC	 |
| Logical      |    CPU      |	VRAM  | dots  |   LMCM	 |
| move	       |    VRAM     |	VRAM  | dots  |   LMMM	 | default
|	       |    VRAM     |	VDP   | dots  |   LMMV	 |
---------------------------------------------------------- 
*/
// (a) LOP to "or"|: operations by code.
#define opHMMC 0xF0
#define opYMMM 0xE0
#define opHMMM 0xD0
#define opHMMV 0xC0
#define opLMMC 0xB0
#define opLMCM 0xA0
#define opLMMM 0x90
#define opLMMV 0x80

#define DIX_RIGHT 0
#define DIY_DOWN 0

// (b) DI to "or"|: scrolling backwards case only, X,Y,X2,Y2 should +DX,+DY
#define DIX_LEFT 4
#define DIY_UP 8

// (b) DI to "or"|: Expanded RAM , default is 0 for VRAM
#define MSX_source_ExpRAM 16
#define MXD_dest_ExpRAM 32
// (b) DI to "or"|: Stop when colour found
#define MSX_EQ_stop 2

typedef struct {
	unsigned int X;		// source X (0 to 511)
	unsigned int Y;		// source Y (0 to 1023)
	unsigned int X2;	// destination X (0 to 511)
	unsigned int Y2;	// destination Y (0 to 1023)
	unsigned int DX; 	// width (0 to 511)
	unsigned int DY; 	// height (0 to 511)
	unsigned char s0;	// set to 0, dummy 1st empty byte sent to chip
	unsigned char DI;	// set to 0 (b), works well from left to right
	unsigned char LOP;	// 0 to copy (a), Logical+Operation ("or"| definitions)	
} MMMtask;

extern	void fLMMM( MMMtask *VDPtask );		// fast copy by structure

	/* SPRITES */

/* 
;  VRAM memory map
; -----------------------------------------------------------------------
; | 0x7400  - 0x75FF 	512 bytes = 32 sprites * 16-lines of colours	|
; |									|
; | 0x7600  - 0x767F 	128 bytes = 32 sprites * 4 bytes of attributes	|
; |									|
; | ..384 bytes		0x7680-0x769F is for main colour palette 	|
; |									|
; | 0x7800  - 0x7FFF 	2Kb bytes = 256 patterns * 8 bytes of points	|
; -----------------------------------------------------------------------
*/
	
// (g) to "or"| with sprite line colour
// Left shifted 32 dots (to get left side sprite)
#define SPRITE_COL_EC	128
// Set sprite priority control (less number above)
#define SPRITE_COL_CC	64
// Set sprite collision detection (not used, keep and check coordinates of each sprite)
#define SPRITE_COL_IC	32

extern	void	Sprites_On( void );	/* Enable Sprites (default) */
extern	void	Sprites_Off( void );	/* Disable Sprites */
extern	void	Sprites_8( void );	/* Set sprites to 8x8 size (default) */
extern	void	Sprites_16( void );	/* Set sprites to 16x16 size */

	/* Define sprite patterns, data of points is array of 8 or 16 bytes (if set), 256x8-byte patterns max. */
extern	void	SpritePattern( int patternNumber, unsigned char *data );
	/* For 16x16 sprites:
		1. Edit vertically 16 x 16-bit integers as bits (0b1111111100000000)
		2. Use this to convert to standard sprite (1-4quadr.) definition 32 char bytes
		Returns pointer to new data */
extern	unsigned char	*Sprite32bytes( unsigned int *bindata );

	/* Set colours of lines for sprite over default mono-colour */
extern	void	SpriteColours( int spriteNumber, unsigned char *data );	// "or"| each byte with EC,CC,IC (g)
	/* Sets sprite attributes, screen position, 32 sprites max.
	The default Y-position in VRAM is 217, so the sprite is "invisible" while setting patters and colours. */
extern	void	SpriteAttribs( int spriteNumber, int patternNumber, int X, int Y );
	/* clear all sprite VRAM */
extern	void	ResetSprites();

extern	void	SpritesSmall( void );		/* Small sprites (default) */
extern	void	SpritesDoubleSized( void );	/* Set magnified-zoom-double size displayed sprites */

/*
(much faster compilation without, should compile 1-time and add .asm code to .rel)

#define	_pt_(h,v) psetXY(X+(h),Y+(v),colour)
#define	_ln_(h,v) LINE(X+(h),Y+(v),X-(h),Y+(v),colour,0)
#define	pt_(h,v) if(OP==0xff)_ln_(h,v);else if(OP!=0xff)_pt_(h,v)

	// circle, add FILL_ALL to fill
extern	void	CIRCLE( int X, int Y, int Radius, int colour, int OP )
	{
	int x = Radius; int y = 0; int e = 0;
	while(1)
		{
		pt_(+x,+y); pt_(+x,-y); pt_(-x,+y); pt_(-x,-y);
		pt_(+y,+x); pt_(+y,-x); pt_(-y,+x); pt_(-y,-x);						
		if (x <= y) break;
		e += (y<<1) + 1; y++;
		if (e > x) { e += 1 - (x<<1); x--; }
		}
	}
*/
	/* Not usable, just exist. It is better use BIOS functions. */
	/* Prepare VDP for direct writing (via port) at page's starting address in VRAM. */
extern	void	Set_VDP_Write( int page );
	/* Prepare VDP for direct reading (via port) at page's starting address in VRAM. */
extern	void	Set_VDP_Read( int page );
