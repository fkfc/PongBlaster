/*
**	CONIO.H
**	Low level console functions
**
**	(c) 1997, SOLID MSX C
*
*
*	SDCC port 2015
*	Uses BIOS only. Very basis, small code.
*
*/

extern char	getch	();		/* read char from console */
extern char	getche	();		/* read and display char from console */
extern void	putch	(char c);	/* display char */
extern void	cputs	(char *s);	/* display string */

extern void	gohome	();		/* set cursor to 0,0 */
extern void	gotoxy	(int x, int y); /* set cursor to x,y */
extern void	clrscr	();		/* clear screen */

extern char	kbhit();		/* checks keypress */
extern void	putdec(int num);	/* displays signed integer value */
					/* -32768 to 32767  (larges code) */

extern void	Mode80();		/* sets MODE 80 */
extern void	Mode40();		/* sets MODE 40 */

					/* sets colors */
extern	void	SetColor( int foreground, int background, int border );


