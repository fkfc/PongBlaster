/*
**	CTYPE.H
**	Character type classification functions
**	
**	(c) 1995, SOLID MSX C
*
*	SDCC port 2015
*/

extern char	tolower	( char c );	/* convert to lowercase */
extern char	toupper	( char c );	/* convert to uppercase */
extern int	isalnum	( char c );	/* A-Za-z0-9 */
extern int	isalpha	( char c );	/* A-Za-z */
extern int	isascii	( char c );	/* !..~ */
extern int	iscntrl	( char c );	/* unprintable control symbol */
extern int	isdigit	( char c );	/* 0..9 */
extern int	isgraph	( char c );	/* has graphic representation */
extern int	islower	( char c );	/* lowercase test */
extern int	isprint	( char c );	/* printable test */
extern int	ispunct	( char c );	/* punctuation sign test */
extern int	isspace	( char c );	/* space test */
extern int	isupper	( char c );	/* uppercase test */
extern int	isxdigit( char c );	/* hex digit test */
