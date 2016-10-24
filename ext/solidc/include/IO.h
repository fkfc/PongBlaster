/*
**	IO.H
**	Disk operations
**	
**	(c) 1995, SOLID MSX C
*
*	SDCC port 2015
*	open file, read, write, append, close
*	folder functions
*
*/


	/*
		For MSXDOS1 use FCB for file operations:
		perform the initialisation FCBs() ,
		also obtains pointer to FCB list reserved for files
	...
	FCBlist *FCB = FCBs();
	
	_os_ver = 1;	// set kind of MSXDOS1 compatibility,  then functions as MKDIR are disabled
	
	int f = open("A.TXT",O_RDWR);
	cputs(FCB->fcb[f].filename);
	
	...
	...
	
	MSXDOS2 is MSXDOS1 backwards compatible and all files can be processed on MSXturboR
	by using same FCB handles as on MSX1. Anyway MSXturboR can manage MSXDOS2 and this library
	switches to CALL 5 functions above 40h. Of course, manually _os_ver = 1 sets it back to MSX1.
	
	For BlueMSX emulator:
	Use http://www.lexlechz.at/en/software/DiskMgr.html to emulate floppy disk images (.dsk),
	otherwise emulator turns read-only mode for directory. 
	
	*/

#define	SEEK_SET	0
#define	SEEK_CUR	1
#define	SEEK_END	2

#define	O_RDONLY	0
#define	O_WRONLY	1
#define	O_RDWR		1
#define	O_CREAT		0x39
#define	O_EXCL		0x04
#define	O_TRUNC		0x31
#define	O_APPEND	0x41
#define	O_TEMP		0x80

	/* get OS version	1-> MSXDOS 1.X, 2-> MSXDOS2, 0-not initiated */
extern	int	get_OS_version( void );
			/* available after get_OS_version */
extern	char	_os_ver;	// MSX-DOS kernel version (better set to 1)
extern	char	_mx_ver;	// MSXDOS2.SYS version number (informational)

// Handbook on FCB at
// http://fms.komkon.org/MSX/Handbook/th-3.txt

//used for MSXDOS1 only
typedef struct {
	unsigned char drive;     // 0: default drive
	unsigned char filename[11];	// 8+3 for extension, as "MYPROG  PRG"
	unsigned int block;
	unsigned int record_size;
	unsigned long file_size;
	unsigned int date;
	unsigned int time;
	unsigned char device;
	unsigned char dir_location;
	unsigned int top_cluster;
	unsigned int lastacsd_cluster;
	unsigned int clust_from_top;
	unsigned char record;
	unsigned long rand_record;
	unsigned char none;	//+1 byte
} FCBstru;	// 38 bytes

typedef struct {
	FCBstru fcb[8];
} FCBlist;

extern	FCBlist *FCBs( void );

extern	int	_io_errno;	/* to see error code in register A after CALL 5 */

	/* FILE READ,WRITE OPERATIONS */

		/* opens file, returns number fH= 3...15 as file handler, or -1 on error */
extern	int	open( char *name, int mode );
		/* opens file providing attributes for MSXDOS2, (attributes = mode, default) */
extern	int	open_a( char *name, int mode, int attr );

		/* creates file, opens, see open */
extern	int	create(char *name);
		/* creates file providing attributes for MSXDOS2, (attributes = mode, default) */
extern	int	create_a(char *name, int attr);

		/* closes file by file handler, returns 0, or -1 on error in _io_error */		
extern	int	close( int fH );

		/* reads from file to buffer */
extern	int	read(int fH, void *buf, unsigned int nbytes);
		/* writes buffer to file */
extern	int	write(int fH, void *buf, unsigned int nbytes);

		/* gets the A: into buffer, returns 0 on success */
extern	int	getcwd(char *buf, int bufsize);

		/* gets current drive number */
extern	int	getdisk();
		/* sets drive number */
extern	void	setdisk(int diskno);

 
extern	FCBlist _buf8_fcbs;	// internal


		/* read file position, returns 0, or error in _io_error.
		address is like 0xABCD, asm will operate as 4-bytes long value
		*/
extern	int	ltell(int fH, unsigned int address_of_long_value);

		/* set file position, returns 0, or error in _io_error.
		ot = 0,1,2. On return long value is set to current record */
extern	int	lseek(int fH, unsigned int address_of_long_value, int ot);	

		
	/* FILE DIRECTORY OPERATIONS */
		/* removes file, returns 0 on success, or error in _io_error */
extern	int	remove(char *filename);
		/* renames file,folder, returns 0 on success, or error in _io_error */
extern	int	rename(char *old_name, char *new_name);
		/* finds files or folders by will-card as "*.COM", "????", etc.
		, returns 0 on success, or error in _io_error.
		Provide 0 or attributes for MSXDOS2. */
extern	int	findfirst(char *willcard, char *result, int attr);
		/* continue search after findfirst */ 
extern	int	findnext(char *result);


/* MSXDOS2 only */
		/* sets current path, returns 0, or error in _io_error */
extern	int	chdir(char *path);
		/* creates folder, returns 0, or error in _io_error */
extern	int	mkdir(char *folderName);
		/* removes folder, returns 0, or error in _io_error */
extern	int	rmdir(char *folderName);


/* MSXDOS1 only file operations c-level, uses FCB file info structure */

#define	B8dH	_buf8_fcbs.fcb[fH]
		/* read file position from FCB */
extern	unsigned long _tell(int fH) { return B8dH.rand_record; }
		/* set file position from FCB */
extern	void _seek(int fH, long pos, int ot)
		{
		if(ot==SEEK_CUR) B8dH.rand_record+=pos;
		else B8dH.rand_record = (ot==SEEK_END ? B8dH.file_size+pos : pos );
		}
		/* get file size */
extern	unsigned long _size(int fH) { return B8dH.file_size; }
/*
 similarly, for DOS1 the other FCB items as .device can be accessible the same way
*/	

		