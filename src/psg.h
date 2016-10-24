#ifndef PSG_H
#define PSG_H


#define PSG_C3 0x358
#define PSG_D3 0x2FA
#define PSG_E3 0x2A6
#define PSG_F3 0x280
#define PSG_G3 0x23A
#define PSG_A3 0x1FC
#define PSG_B3 0x1C6
#define PSG_C4 0x1AC
#define PSG_D4 0x17D
#define PSG_E4 0x153
#define PSG_F4 0x140
#define PSG_G4 0x11D
#define PSG_A4 0x0FE
#define PSG_B4 0x0E3
#define PSG_C5 0x0D6
#define PSG_D5 0x0BE
#define PSG_E5 0x0A9
#define PSG_F5 0x0A0
#define PSG_G5 0x08E
#define PSG_A5 0x07F
#define PSG_B5 0x071


void psg_write( unsigned char psgreg, unsigned char data ) ;

unsigned char psg_read( unsigned char psgreg );

void playTest();


#endif
