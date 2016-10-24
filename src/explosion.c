#include "explosion.h"
#include "defines.h"
#include <types.h>
#include "graph_aux.h"
#include <VDPgraph2.h>
#include "psg.h"


const unsigned char EXPLOSION_SOUND_1 = 0b00011000; //inv freq
const unsigned char EXPLOSION_SOUND_2 = 0b00011100; //inv freq
const unsigned char EXPLOSION_SOUND_3 = 0b00011110; //inv freq
const unsigned char EXPLOSION_SOUND_4 = 0b00011111; //inv freq

int explosionSpriteId;

void explosionSetup() {
    
    const unsigned int pattern1[] = {
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000001111000000,
            0b0000011111100000,
            0b0000111111110000,
            0b0000111001110000,
            0b0000111001110000,
            0b0000111111110000,
            0b0000011111100000,
            0b0000001111000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000
    };
    
        
    const unsigned int pattern2[] = {
            0b0000000000000000,
            0b0000011111100000,
            0b0000110111110000,
            0b0001110111111000,
            0b0011110011011100,
            0b0111110010011110,
            0b0110011000111010,
            0b0110000000100010,
            0b0111111000001110,
            0b0111110001111110,
            0b0011100100111110,
            0b0001001110011110,
            0b0001111110011100,
            0b0000111111111000,
            0b0000011111100000,
            0b0000000000000000
    };

    const unsigned int pattern3[] = {
            0b0000001111000000,
            0b0000111111110000,
            0b0001000110001000,
            0b0010000010001100,
            0b0110000000001110,
            0b0111000000011110,
            0b1111100000010011,
            0b1000000000000011,
            0b1000000000000001,
            0b1110000000000001,
            0b0111110000000010,
            0b0111100000111110,
            0b0011000000011100,
            0b0001000100011000,
            0b0000101110110000,
            0b0000011111000000      
    };

    const unsigned int pattern4[] = {
            0b0000001111000000,
            0b0000110000110000,
            0b0001000000001000,
            0b0010000000000100,
            0b0100000000000010,
            0b0100000000000010,
            0b1000000000000001,
            0b1000000000000001,
            0b1000000000000001,
            0b1000000000000001,
            0b0100000000000010,
            0b0100000000000010,
            0b0010000000000100,
            0b0001000000001000,
            0b0000100000110000,
            0b0000011111000000
    };
    
    
    const unsigned int pattern5[] = {
            0b0000001110000000,
            0b0000110000010000,
            0b0000000000001000,
            0b0010000000000000,
            0b0000000000000010,
            0b0100000000000010,
            0b1000000000000000,
            0b0000000000000001,
            0b0000000000000000,
            0b1000000000000001,
            0b0100000000000010,
            0b0000000000000000,
            0b0010000000000100,
            0b0001000000000000,
            0b0000000000110000,
            0b0000011001000000
    };
    
      
    
    const char colors[]= {
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
        EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR,
	EXPLOSION_COLOR
    };

        
    VDP.setSprite(EXPLOSION_SPRITE, VDP.addPattern(pattern1), VDP.addColorLine(colors) );
    VDP.setSprite(EXPLOSION_SPRITE+1, VDP.addPattern(pattern2), VDP.addColorLine(colors) );
    VDP.setSprite(EXPLOSION_SPRITE+2, VDP.addPattern(pattern3), VDP.addColorLine(colors) );
    VDP.setSprite(EXPLOSION_SPRITE+3, VDP.addPattern(pattern4), VDP.addColorLine(colors) );
    VDP.setSprite(EXPLOSION_SPRITE+4, VDP.addPattern(pattern5), VDP.addColorLine(colors) );
}

void explosionShow(int x, int y) {
    unsigned int timer;
    
    
    psg_write( 6, EXPLOSION_SOUND_1 ); //reg 6 = noise tone
    psg_write( 8, 12 ); // reg 8 = volume ch A
    psg_write( 7, 0b10110111 ); //reg 7 = mixer. enable noise ch A
    
    
    
    
    
    VDP.moveSprite(EXPLOSION_SPRITE, x-8, y-8);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    VDP.moveSprite(EXPLOSION_SPRITE+1, x-8, y-8);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    psg_write( 6, EXPLOSION_SOUND_2 ); //reg 6 = noise tone
    
    
    VDP.moveSprite(EXPLOSION_SPRITE, 0, 217);  
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    VDP.moveSprite(EXPLOSION_SPRITE+2, x-8, y-8);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    psg_write( 6, EXPLOSION_SOUND_3 ); //reg 6 = noise tone
    
    VDP.moveSprite(EXPLOSION_SPRITE+1, 0, 217);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    VDP.moveSprite(EXPLOSION_SPRITE+3, x-8, y-8);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    VDP.moveSprite(EXPLOSION_SPRITE+2, 0, 217);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    psg_write( 6, EXPLOSION_SOUND_4 ); //reg 6 = noise tone
    
    VDP.moveSprite(EXPLOSION_SPRITE+4, x-8, y-8);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    VDP.moveSprite(EXPLOSION_SPRITE+3, 0, 217);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    VDP.moveSprite(EXPLOSION_SPRITE+4, 0, 217);
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);
    
    //explosion (noise) fade out 
    psg_write( 8, 12 ); // reg 8 = volume ch A
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);    
    psg_write( 8, 10 ); // reg 8 = volume ch A
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);    
    psg_write( 8, 8 ); // reg 8 = volume ch A
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);    
    psg_write( 8, 6 ); // reg 8 = volume ch A
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);    
    psg_write( 8, 4 ); // reg 8 = volume ch A
    for (timer = EXPLOSION_ANIMATION_TIMER; timer > 0; timer--);    
    psg_write( 8, 2 ); // reg 8 = volume ch A
    
    
    
    
    psg_write( 7, 0b10111000 ); //reg 7 = mixer. disable noise ch A
    psg_write( 8, 0 ); // reg 8 = volume ch A
    
}

void explosionHide() {
    VDP.moveSprite(EXPLOSION_SPRITE, 0, 217);
    VDP.moveSprite(EXPLOSION_SPRITE+1, 0, 217);
    VDP.moveSprite(EXPLOSION_SPRITE+2, 0, 217);
    VDP.moveSprite(EXPLOSION_SPRITE+3, 0, 217);
    VDP.moveSprite(EXPLOSION_SPRITE+4, 0, 217);
}

const t_explosion Explosion = {
    .setup = explosionSetup,
    .show = explosionShow,
    .hide = explosionHide
};
