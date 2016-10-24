//PSG pag em japones http://qiita.com/ohisama@github/items/7bdd701f3a9dca231fe1

#include "psg.h"
#include <types.h>
#include <ioport.h>
/*
-------------------------------------------------------------------------------
PSG制御命令
	void psg_write( unsigned char psgreg, unsigned char data );
		PSG のレジスタ psgreg に data を書き込みます。

		PSG レジスタ		意味
		0					ch.A の周波数(LOW)
		1					ch.A の周波数(HIGH)
		2					ch.B の周波数(LOW)
		3					ch.B の周波数(HIGH)
		4					ch.C の周波数(LOW)
		5					ch.C の周波数(HIGH)
		6					ノイズ周波数
		7					チャンネル設定
		8					ch.A 音量
		9					ch.B 音量
		10					ch.C 音量
		11					エンベロープ周期(LOW)
		12					エンベロープ周期(HIGH)
		13					エンベロープパターン
		14					I/O port A
		15					I/O port B

	unsigned char psg_read( unsigned char psgreg );
		※未検証
		PSG のレジスタ psgreg を読み込みます。
		
		
-------------------------------------------------- -----------------------------
Instrução de controle PSG
void psg_write( unsigned char psgreg, unsigned char data );
Grava os dados no registro PSG




registro PSG            significado
0                       Ch.A de frequência (baixo)
1                       Ch.A de frequência (ALTA)
2                       CH.B de frequência (baixo)
3                       CH.B de frequência (ALTA)
4                       ch.C de frequência (baixo)
5                       ch.C de frequência (ALTA)
6                       Frequência  de ruído
7                       Definição  canais
8                       volume de Ch.A
9                       de volume CH.B
10                      volume de ch.C
11                      Período de  envelope (LOW)
12                      Período de  envelope (ALTA)
13                      Padrão  envelope
14                      I / O port A
15                      I / O port B

unsigned char psg_read( unsigned char psgreg );
Leia o registro psgreg PSG.

*/

void psg_write( unsigned char psgreg, unsigned char data ) {
	out( 0xA0, psgreg );
	out( 0xA1, data );
}

unsigned char psg_read( unsigned char psgreg ) {
	out( 0xA0, psgreg );
	return in( 0xA2 );
}



/* --------------------------------------------------------- */
/*	PSG test												 */
/* ========================================================= */
/*	2006/11/25	t.hara										 */
/* --------------------------------------------------------- */

/* --------------------------------------------------------- */
//12 bits de resolução (3 caracteres hexa)
//freq final = 111.861 Hz / (valor no registro)
//ex: registro = 0x0FE (254):  111861/254 = 440Hz  = Lá 
static const unsigned int tone_freq[] = {

	/* C4     D4     E4     F4     G4     A4     B4     C5  end mark */
	0x1AC, 0x17D, 0x153, 0x140, 0x11D, 0x0FE, 0x0E3, 0x0D6, 0,
};

/* --------------------------------------------------------- */
static void wait( int j ) {
	volatile int i;

	for( i = 0; i < j; i++ ) {
	}
}

/* --------------------------------------------------------- */
static void psg_init( void ) {
	int i;

	for( i = 0; i < 16; i++ ) {
		psg_write( i, 0 );
	}
	psg_write( 7, 0x3F );
}

/* --------------------------------------------------------- */
void playTest( ) {
	int i;
        unsigned char r;
	//psg_init();
        
	psg_write( 7, 0b10111000 );	/* mixer */

	for( i = 0; tone_freq[i] ; i++ ) {
		//printf( "tone = %03x\n", tone_freq[i] );
		//psg_write( 0, (unsigned char)tone_freq[i] );			/* freq. low */
		//psg_write( 1, (unsigned char)(tone_freq[i] >> 8) );		/* freq. high */
            
                //CHANNEL A
                psg_write( 0, (unsigned char)tone_freq[i] );			/* freq. low */
		psg_write( 1, (unsigned char)(tone_freq[i] >> 8) );		/* freq. high */
                
                
                //CHANNEL B
                psg_write( 2, (unsigned char)   tone_freq[(i + 2)%7]       );		/* freq. low */
                psg_write( 3, (unsigned char)  (tone_freq[(i + 2)%7]  >> 8) );		/* freq. high */
                
                
                //CHANNEL C
                psg_write( 4, (unsigned char)   tone_freq[(i + 4)%7]       );		/* freq. low */
                psg_write( 5, (unsigned char)  (tone_freq[(i + 4)%7]  >> 8) );		/* freq. high */
                
                
		psg_write( 8, 15 );						/* volume */
                psg_write( 9, 15 );						/* volume */
                psg_write(10, 15 );						/* volume */
                
		wait( 7000 );
                
		//psg_write( 8, 0 );	               				/* volume */
                //psg_write( 9, 0 );	               				/* volume */
                //psg_write(10, 0 );						/* volume */
		//wait( 1000 );
	}
	
	psg_write( 8, 0 );	               				/* volume */
        psg_write( 9, 0 );	               				/* volume */
        psg_write(10, 0 );						/* volume */

	//psg_init();
}




/*
#define WRTPSG      #0x0093



void setpsg(unsigned char e, unsigned char a) {
    __asm
    ld      e, 4(ix)
    ld      a, 5(ix)
    call    WRTPSG
    __endasm;
}



void wait(int t)
{
    while(t--);
} 



void daPlayMacaco()
{
    const unsigned int psg[] = {
        0xaa, 0xaa, 0xaa, 0xa0, 0xaa, 0xaa, 0xd6, 0xd6, 0xbe, 0xbe,
        0xd6, 0xbe, 0xaa, 0x10d, 0xe3, 0xaa, 0xaa, 0xaa, 0xa0, 0xaa,
        0xaa, 0xd6, 0xbe, 0xbe, 0xd6, 0xe3, 0xfe, 0x7f, 0x7f, 0x7f,
        0x7f, 0x7f, 0x7f, 0xaa, 0xaa, 0xaa, 0xaa, 0xa0, 0x8f, 0xa0,
        0xaa, 0xaa, 0xa0, 0xaa, 0xaa, 0xd6, 0xd6, 0xbe, 0xbe, 0xd6,
        0xe3, 0xfe, 0x153, 0x153, 0x140, 0x153, 0x153, 0x1ac, 0x1ac,
        0x17d, 0x17d, 0x1ac, 0x17d, 0x153, 0x153, 0x153, 0x140, 0x153,
        0x153, 0x1ac, 0x1ac, 0x17d, 0x17d, 0x1ac, 0x01c5, 0x01fc, 0x7f, 0x7f,
        0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0xaa, 0xaa, 0xaa, 0xa0, 0x8f, 0xa0,
        0xaa, 0xaa, 0xa0, 0xaa, 0xaa, 0xd6, 0xd6, 0xbe, 0xbe, 0xd6, 0xe3,
        0xfe
    };
    
    unsigned int i, j, e, a;
    i = j = e = a = 0;
    a = 0x07;
    e = 0xfe;
    setpsg(e, a);
    
    for (i = 0; i < 101; i++)
    {
        e = psg[i] & 0xff;
        a = 0x00;
        setpsg(e, a);
        e = (psg[i] >> 8) & 0xff;
        a = 0x01;
        setpsg(e, a);
        e = 0x05;
        a = 0x08;
        setpsg(e, a);
        wait(98000);
        e = 0x00;
        a = 0x08;
        setpsg(e, a);
        wait(2000);
    }
    
    
}
*/