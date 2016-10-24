/*
**	string.h
**	String manipulation functions
**
**	(c) 1995, SOLID MSX C
*
*	SDCC port 2015
*	This somehow duplicates the original string.h,  even with larger code.
*
*/


	/* copy string from src to dst */
extern	void	strcpy( char *dst, char *src );

	/* copy string from src to dst with no more than n characters */
extern	void	strncpy( char *dst, char *src, int n );

	/* concatenate string from src to dst */
extern	void	strcat( char *dst, char *src );

	/* concatenate string from src to dst with no more than n characters */
extern	void	strncat( char *dst, char *src, int n );

	/* returns length of string */
extern	int	strlen( char *adr );

	/* compares two strings s1 and s2,
	 returns -1 (s1<s2), 0 (s1=s2), 1 (s1>s2)  */
extern	int	strcmp( char *s1, char *s2 );

	/* compares two strings s1 and s2, no more than n characters,
	 returns -1 (s1<s2), 0 (s1=s2), 1 (s1>s2)  */
extern	int	strncmp( char *s1, char *s2, int n );

	/* returns i, for which adr[i] = c, or -1 if not found*/
extern	int	strchr( char *adr, char c );

	/* finds substring s2 in string s1 and returns position s1[i],
	returns -1 if not found */
extern  int	strstr( char *s1, char *s2 );

	/* returns the the first occurrence in the string s1
	of any character from the string s2, or -1 if not found */
extern	int	strpbrk( char *s1, char *s2 );

	/* returns the last i, for which adr[i] = c, or -1 if not found */
extern	int	strrchr( char *adr, char c );

	/* converts string to upper-case at address adr */
extern	void	strupr( char *adr );

	/* converts string to lower-case at address adr */
extern	void	strlwr( char *adr );

	/* removes left spaces */
extern  void	strltrim( char *adr );

	/* removes right spaces */
extern  void	strrtrim( char *adr );

	/* replaces all chars c to nc in string adr */
extern	void	strreplchr( char *adr, char c, char nc );

/*
(faster compilation without)

//	replaces all sub-strings s1 with s2 in string adr,
//	uses memory right below code (heap_top=length of program+few bytes)
//	that should be free of data or code loaded after at runtime 

extern unsigned char *heap_top;

extern	void	strreplstr( char *adr, char *s1, char *s2 )
 {
 int i=0, l1 = strlen(s1);
 unsigned char *p = (void *)heap_top;		// free memory space below code
 
 while(1)
	{
	i = strstr(adr,s1);
	if(i<0) break;
	strncpy(p,adr,i);
	strcat(p,s2);
	strcat(p,adr+i+l1);
	strcpy(adr,p);
	}
 }

*/