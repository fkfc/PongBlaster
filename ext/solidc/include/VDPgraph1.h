/*
*	VDPgraph1.h	- MSX1,
*			 also MSX2 compatible graphics VDP functions.
*
*	Compile on SDCC for MSX
*
*	This works on MSXDOS, built above, not BASIC ROM, sorry.
*
*	Screen 2 for  MSX2 is backwards compatible graphics, not actual for hardware of that time.
*	There is limit: for each 8-pixels horizontally only 2 colours possible.
*	So, graphics of drawings looks awkward! Anyway, games as Arkanoid use exactly 8-pixel
*	 drawings and graphics looks perfect. Do this way and will get all MSX compatible
*	 good looking game.
*	TMS9918 VDP chip of MSX1 lacks fast built-in graphics copying functions RAM-VRAM-VRAM.
*	Single colour sprites 8x8,16x16 are supported.
*
*	SCREEN 2 mode resolution 256 pixels x 192 lines (16kB for screen)
* --------------------------------------------------------------------------
* | screen:		32 (horizontal) x 24 (vertical) patterns	   |
* |			16 from 512 colours can be displayed		   |
* |			at the same time				   |
* | pattern:		768 kinds of patterns are available		   |
* |			pattern size is 8 (horizontal) x 8 (vertical) dots |
* |			any Figure can be defined for each pattern	   |
* |			only two colours can be used in horizontal 8 dots  |
* | memory:		for pattern font  6144 bytes	   		   |
* |    required:	for colour table  6144 bytes	   		   |
* | sprite:		sprite mode 1, 32 mono-colour sprites		   |
* | colours:		static table of MSX 16 colours			   |
* | BASIC:		compatible to SCREEN 2 for GRAPHIC 2		   |
* --------------------------------------------------------------------------
*
*	Memory map:	
*
*	0x0000 - 0x17FF		6144 bytes pattern generator (3 blocks x 256 patterns of 8 bytes)
*	0x1800 - 0x1AFF		768 bytes pattern layout (textual representation of 32x24 screen)
*	0x1B00 - 0x1B7F		128 bytes for sprite attributes
*	0x2000 - 0x37FF		6144 bytes pattern colours
*				(for "0" and "1")2 x 4bits per colour x 256 patterns of 8 bytes
*	0x3800 - 0x3FFF		2048 (256 x 8) bytes for sprite patterns
*
*/

extern	int	vMSX( void );		/* 1-MSX1, 2-MSX2 */
extern	void	Save_VDP( void );	/* Save VDP on start-up */
extern	void	Restore_VDP( void );	/* Restore VDP on exit, be correct! */
extern	void	SetScreen2( void );	/* SCREEN 2 (256x192 x 16colours) */
extern	void	SetScreen0( void );	/* SCREEN 0 when returning back */
	/* Clears screen. Puts background colour in VRAMs patterns. Use after SetColors().  */
extern	void	ClearScreen( void );
extern	void	DisableScreen( void );	/* Disables output to screen, "freezes display" as it is */
extern	void	EnableScreen( void );	/* Enables output to screen, SPRITES, display is updated */
			/* Sets foreground,background,border colour by number 0..15 */
extern	void	SetColors( int ForeCol, int BackgrCol, int BorderCol );
extern	void	SetBorderColor( int colour );	/* Sets background colour by number 0..15 */

	/* Prints string on graphics screen at position X=[0..255],Y=[0..191]
		String ends with 0 */
extern	void	PutText( int X, int Y,  char *str );		

	/* Whole screen RAM <=> VRAM dumb copy (2 x  0x1800 bytes) */
		
	/* Writes screen from RAM memory addresses to VRAM, very dumb one time way (2x6144 bytes) */
extern	void	Write_Scr( unsigned int addr_fromPalettes, unsigned int addr_fromColours );
	/* Reads screen from VRAM to memory addresses, very dumb one time way (2x6144 bytes) */
extern	void	Read_Scr( unsigned int addr_toPalettes, unsigned int addr_toColours );

	/*
		VRAM => RAM (copy block to memory)
		(X,Y) - left upper corner of screen position to copy
		dx,dy - count of columns and rows of pixels
		So, the block (X,Y)-(X+dx-1,Y+dy-1) will be copied. 
		X,dx should be 0,8,16,24,32,... 8*n  because
		complete 8-pixel patterns will be copied
		Requires 2 memory blocks size of   (dx/8)*dy
	*/
extern	void	Read_Block( int X, int Y, int dx, int dy, 
			unsigned int addr_toPalettes, unsigned int addr_toColours );
	/*
		RAM => VRAM (put from memory to screen)
		(X,Y) - where to put on screen
		Opposite to Read_Block().
	*/
extern	void	Write_Block( int X, int Y, int dx, int dy,
			unsigned int addr_fromPalettes, unsigned int addr_fromColours );

	/* keyboard controls */
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
	/* verifies MSX keyboard status by ports 0xAA,0xA9 */
extern	int	keyboard_read( void );

extern	void	_ei_halt( void );	/* EI+HALT to make delays */


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

	/* 8-pixel pattern functions, that does not change colour */		
		/* get byte of 8-pixels at (X,Y). b11001000 means: 0,1,4 pixel is set. */
extern	int	get8px( int X,  int Y );
		/* get pixel of 8-pixels at (X,Y). Returns 0 if not set. */
extern	int	get1px( int X,  int Y );

		/* sets whole byte of 8-pixels at (X,Y) */
extern	void	set8px( int X,  int Y );
		/* sets pixel of 8-pixels at (X,Y) */
extern	void	set1px( int X,  int Y );

		/* clears byte (sets=0) of 8-pixels at (X,Y) */
extern	void	clear8px( int X,  int Y );
		/* clears pixel (sets=0) of 8-pixels at (X,Y) */
extern	void	clear1px( int X,  int Y );

	/* structure to set/get colour of 8 pixels */
typedef struct {
	int col;	// colour number 0..15 for pixels of pattern
	int bg;		// background colour number 0..15
} pxColor; 

	/* colour functions */
		/* get colours of 8-pixel pattern at (X,Y) */
extern	void	getCol8px( int X,  int Y, pxColor *C );
		/* sets new colour in (X,Y) for 8-pixel pattern */
extern	void	setCol8px( int X,  int Y, pxColor *C );
	
	/* functions that we know, by ignoring same 8-pixel pattern */
		/* gets colour 0..15 of pixel at (X,Y), the same for 8-pixel pattern  */
extern	int	POINT( int X,  int Y );
		/* puts pixel in (X,Y), sets colour of whole 8-pixel pattern */
extern	void	PSET( int X,  int Y, int color );

	/* draws line (X,Y)-(X2,Y2), sets pixels, sets colour, does not change background colour */
extern	void	LINE( int X,  int Y, int X2,  int Y2, int color );

#define	NO_FILL		0x00
// filling operation for rectangle and circle
#define	FILL_ALL	0xFF

		/* draws rectangle (X,Y)-(X2,Y2), with filling operation,
		fills if OP is FILL_ALL */
extern	void	RECT( int X1, int Y1, int X2, int Y2, int colour, int OP );

/* Paint for small regions. Split them if large.
	It is not the BASIC-subROM paint! Kind of bugPaint.
	Requires large stack of memory, slower than any image processing.
	Paint stops when "set" pixel is reached, not exact colour. Sets colour for whole pattern.
	*/
extern	void	PAINT( int X, int Y, int colour );

	/* Remake of BASICs "draw" with original commands (except A,X) syntax. */
extern	void	DRAW( char *drawcommands );


	/* SPRITES */

/* 
*	VRAM memory map
*	0x1B00 - 0x1B7F		128 bytes for sprite attributes
*	0x3800 - 0x3FFF		2048 (256 x 8) bytes for sprite patterns
*/
	
// (g) to "or"| with sprite line colour
// Left shifted 32 dots (to get left side sprite)
#define SPRITE_COL_EC	128
// Set sprite priority control (less number above)
#define SPRITE_COL_CC	64
// Set sprite collision detection (not used, keep and check coordinates of each sprite)
#define SPRITE_COL_IC	32

extern	void	Sprites_8( void );	/* Set sprites to 8x8 size (default) */
extern	void	Sprites_16( void );	/* Set sprites to 16x16 size */

	/* Define sprite patterns, data of points is array of 8 or 16 bytes (if set), 256x8-byte patterns max. */
extern	void	SpritePattern( int patternNumber, unsigned char *data );
	/* For 16x16 sprites:
		1. Edit vertically 16 x 16-bit integers as bits (0b1111111100000000)
		2. Use this to convert to standard sprite (1-4quadr.) definition 32 char bytes
		Returns pointer to new data */
extern	unsigned char	*Sprite32bytes( unsigned int *bindata );

	/* Sets sprite attributes, screen position, colour (g), 32 sprites max. */
extern	void	SpriteAttribs( int spriteNumber, int patternNumber, int X, int Y, int colour );
	/* clear all sprite VRAM */
extern	void	ResetSprites();

extern	void	SpritesSmall( void );		/* Small sprites (default) */
extern	void	SpritesDoubleSized( void );	/* Set magnified-zoom-double size displayed sprites */

/*
(much faster compilation without, should compile 1-time and add .asm code to .rel)

#define	_pt_(h,v) PSET(X+(h),Y+(v),colour)
#define	_ln_(h,v) LINE(X+(h),Y+(v),X-(h),Y+(v),colour)
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
