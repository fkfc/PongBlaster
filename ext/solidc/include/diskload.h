/*
*	Diskload - load binary file from disk to RAM.
*			Do not expect loading .ROM or .BIN files this way.
*			Floppy disk size is much greater than RAM,
*			 so we may split data or code and load on runtime.
*			The BlueMSX emulator can use directory as disk just by click in menu,
*				so we can develop and test our code.
*
*	Compile on SDCC for MSX 
*	
*	int diskload( char* filename, unsigned int address, unsigned int runat_address );
*
*		filename - 11 chars DOS1 for FCB, as "MYFILE  DAT"
*		address - where to load the first byte
*		runat_address - if not 0, then where to CALL <runat_address> after loaded
*
*	returns 0 on success
*	
*/

extern	int diskload( char* filename, unsigned int address, unsigned int runat );