/*
**	DOS.h
**	Definitions for dealing with MSXDOS, also BIOS
**
**	(C) 1995, SOLID MSX C
*
*
*	SDCC port 2015
*/


	/* Internal, get pointer by _REGs() function.
	Set before calling intdos().
	Check data after intdos() call, except ix,iy that are the same.
	Cf=1 if carry flag set, Zf=1 if zero flag set */
typedef struct {
	unsigned int af, bc, de, hl, ix, iy, Cf, Zf;	/* 2 registers 0..65535 */
} REGS;

typedef struct {
	int hour;	/* Hours 0..23 */
	int min;	/* Minutes 0..59 */
	int sec;	/* Seconds 0..59 */
} TIME;

typedef struct {
	int year;	/* Year 1980...2079 */
	int month;	/* Month 1=Jan..12=Dec */
	int day;	/* Day of the month 1...31 */
	int dow;	/* On getdate() gets Day of week 0=Sun...6=Sat */
} DATE;

extern void	getdate (DATE *date);  	/* get date */
extern void	gettime (TIME *time);	/* get time */
extern int	setdate (DATE *date);  	/* set date, returns 0 if valid */
extern int	settime (TIME *time);	/* set time, returns 0 if valid */

extern REGS	*_REGs( void );	//* this returns address to internal word registers */
extern void	intdos();		// CALL 5
extern void	intbios();		// CALL 1Ch (RST 30h), set IX,IY
 

	/* Stop processor execution, paused wait for interrupts. */
extern	void	_suspend( void );	// ei+halt
	/* Stop processor and freeze. */
extern	void	_halt( void );		// di+halt
	
extern	void	_di( void );	/* Disable interrupts */
extern	void	_ei( void );	/* Enable interrupts */
