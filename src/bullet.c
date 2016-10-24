#include "bullet.h"
#include "defines.h"
#include <types.h>
#include "graph_aux.h"
#include <VDPgraph2.h>
#include "paddle.h"
#include "psg.h"
#include "sound_manager.h"

const unsigned int  PADDLE_SHOOT_SOUND[] = { PSG_B5, PSG_G4 };
const unsigned char PADDLE_SHOOT_SOUND_SIZE = 2;
//unsigned char bullet_lastP1 = 0;

t_bullet Bullet[BULLET_TOTAL];
char triggerEnabled[2];

int bullet_f1_1, bullet_f1_2, bullet_f2_1, bullet_f2_2; //limiares inferior e superior de fronteira de colisão com os paddles (coordenadas de eixo x)
int bullet_paddle1_halfsize, bullet_paddle2_halfsize; //metade do tamanho dos paddles

//carrega os sprites
void bulletSetup() {
    t_paddle *paddle1, *paddle2;
    char i;

    const unsigned int sprite1[] = {
            0b0000000000000000,
            0b0000000000000000, 
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b1000100101011011,
            0b1000100101011011,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000, 
            0b0000000000000000
    }; 
    
    const unsigned int sprite2[] = {
            0b0000000000000000,
            0b0000000000000000, 
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b1101101010010001,
            0b1101101010010001,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000, 
            0b0000000000000000
    }; 
    
    const char line[]= {
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_YELLOW,
	LIGHT_YELLOW,
	DARK_YELLOW,
        DARK_YELLOW,
	LIGHT_YELLOW,
	LIGHT_YELLOW,
	DARK_RED,
	DARK_RED,
	DARK_RED,
	DARK_RED,
	DARK_RED
    };
        
   
    
    for (i = 0; i < BULLET_PER_PADDLE; i++) {
        Bullet[i].x = -1;
        Bullet[i].y = SCREEN_H/2;
        VDP.setSprite(BULLET_SPRITE+i, VDP.addPattern(sprite1), VDP.addColorLine(line) );
    }
    for (; i < BULLET_TOTAL; i++) {
        Bullet[i].x = -1;
        Bullet[i].y = SCREEN_H/2;
        VDP.setSprite(BULLET_SPRITE+i, VDP.addPattern(sprite2), VDP.addColorLine(line) );
    }
    
    triggerEnabled[0] = 1;
    triggerEnabled[1] = 1;
    
    
    //variaveis pre-calculadas para calcular colisao
    paddle1 = Paddles.getPaddle(0);
    paddle2 = Paddles.getPaddle(1);
    
    bullet_f1_1 = (paddle1->x >> COORD_SHIFT) + BULLET_SPEED; //entrada
    bullet_f1_2 = (paddle1->x >> COORD_SHIFT) - BULLET_SPEED; //saida
    
    bullet_f2_1 = (paddle2->x >> COORD_SHIFT) - BULLET_SPEED; //entrada
    bullet_f2_2 = (paddle2->x >> COORD_SHIFT) + BULLET_SPEED; //saida
    
    bullet_paddle1_halfsize = (paddle1->size >> COORD_SHIFT)/2;
    bullet_paddle2_halfsize = (paddle2->size >> COORD_SHIFT)/2;
}

void bulletReset() {
    char i;
    
    for (i = 0; i < BULLET_TOTAL; i++) {
        Bullet[i].x = -1;
        Bullet[i].y = SCREEN_H/2;
        VDP.moveSprite(BULLET_SPRITE+i, 0, 217);
    }
}

//desenha os tiros
void bulletDraw() {
   char i;
   for (i = 0; i < BULLET_PER_PADDLE; i++) { //tiros do player 1
       if (Bullet[i].x > 0) {
        VDP.moveSprite(BULLET_SPRITE+i, (Bullet[i].x-16), (Bullet[i].y-8));    
        Bullet[i].x += BULLET_SPEED;
        if (Bullet[i].x > SCREEN_W) { //chegou ao fim da tela (direita)
            //bullet_lastP1++;
            //if (bullet_lastP1 == BULLET_PER_PADDLE) bullet_lastP1 = 0;
            Bullet[i].x = -1; 
            VDP.moveSprite(BULLET_SPRITE+i, (Bullet[i].x-16), 217);
        }
       }
   }
   for (; i < BULLET_TOTAL; i++) { //tiros do player 2
       if (Bullet[i].x > 0) {
        VDP.moveSprite(BULLET_SPRITE+i, (Bullet[i].x), (Bullet[i].y-8));    
        Bullet[i].x -= BULLET_SPEED;
        if (Bullet[i].x < 2) { //chegou ao fim da tela (esquerda)
            Bullet[i].x = -1; 
            VDP.moveSprite(BULLET_SPRITE+i, (Bullet[i].x-16), 217);
        }
       }
   }
   
}

void bulletShoot(char paddleId) {
    if (triggerEnabled[paddleId]) {
        char i = paddleId*BULLET_PER_PADDLE;
        char f = i + BULLET_PER_PADDLE;
        while (i < f && Bullet[i].x > 0) i++;
        if (i < f) { //havia bullet disponível
            Bullet[i].x = Paddles.getPaddle(paddleId)->x >> COORD_SHIFT;
            Bullet[i].y = Paddles.getPaddle(paddleId)->y >> COORD_SHIFT;
            triggerEnabled[paddleId] = 0;
            
            if (paddleId == 0) {
                SoundManager.play(SOUND_MANAGER_CHANNEL_B, PADDLE_SHOOT_SOUND, PADDLE_SHOOT_SOUND_SIZE);
            } else {
                SoundManager.play(SOUND_MANAGER_CHANNEL_C, PADDLE_SHOOT_SOUND, PADDLE_SHOOT_SOUND_SIZE);
            }
            
        }
    }
}

//calcula colisao
unsigned char bulletHit() {
   char i;
   int y1, y2;

   y1 = (Paddles.getPaddle(0)->y >> COORD_SHIFT);
   y2 = (Paddles.getPaddle(1)->y >> COORD_SHIFT);

   
   //tiros do player 1 acertam player2
   for (i = 0; i < BULLET_PER_PADDLE; i++) {
       if (Bullet[i].x >= bullet_f2_1) { //passou a fronteira (bullet perto do player)
           if ((Bullet[i].x < bullet_f2_2) &&
               (Bullet[i].y > y2 - bullet_paddle2_halfsize) &&
               (Bullet[i].y < y2 + bullet_paddle2_halfsize)
           ) return 1; //player 1 acertou
       }
   }
   
   //tiros do player 2 acertam player1
   for (; i < BULLET_TOTAL; i++) {
       if (Bullet[i].x <= bullet_f1_1) { //passou a fronteira (bullet perto do player)
           if ((Bullet[i].x > bullet_f1_2) &&
               (Bullet[i].y > y1 - bullet_paddle1_halfsize) &&
               (Bullet[i].y < y1 + bullet_paddle1_halfsize)
           ) return 2; //player 2 acertou
       }
   }
   
   //ninguem acertou
   return 0;
}
