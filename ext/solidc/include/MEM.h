/*
**	MEM.h
**	Memory manipulation functions
**
**	(c) 1995, SOLID MSX C
*
*	SDCC port 2015
*/

#ifndef	NULL
#define	NULL	(void *)0
#endif

	/* returns pointer to char in n bytes of adr, or NULL if not found*/
extern char	*memchr( char *adr, char c, int n );

	/* set n bytes of adr to char c */ 
extern void	memset( char *adr, char c, int n );

	/* copy n bytes from src to dst */
extern void	memcpy( char *dst, char *src, int n );

	/* compares n bytes of s1 and s2,
	 returns -1 (s1<s2), 0 (s1=s2), 1 (s1>s2)  */
extern int memcmp( char *s1, char *s2, int n );

extern unsigned char *heap_top; 
	/* SDCC version of malloc,
	memory right below the code (heap_top=length of program+few bytes)
	should be free of data or code loaded after at runtime 
	*/
extern void *malloc(unsigned int size) {
	unsigned char *ret = heap_top;
	heap_top += size;
	return (void *) ret;
} 
