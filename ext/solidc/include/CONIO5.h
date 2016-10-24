/*
**	CONIO.H
**	Low level console functions
**
**	(c) 1997, SOLID MSX C
*
*
*
*	SDCC port 2015
*	Extended CONIO, uses DOS functions CALL 5
*
*/ 

extern void	putchar	(char c);	/* display char */
extern char	getchar	();		/* get char from input */


/*
 get char from input and display, \n goes next line, BS previous
*/
extern char	getcon();		
					 

/*
 String input from console.

 parameters:
	dest - pointer of buffer where to store entered string
	len - [0..255] is length of buffer dest,
		and user can enter (len-2) chars, max.length=253

 returns length of string
*/

extern int	getscon(char *dest, int len);