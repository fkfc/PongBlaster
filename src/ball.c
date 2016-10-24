#include "ball.h"
#include "defines.h"
#include <types.h>
#include "graph_aux.h"
#include <VDPgraph2.h>
#include "sincos.h"

t_ball Ball;

//carrega os sprites
void ballSetup() {
    
    const unsigned int sprite16[] = {
            0b0000011111100000, 
            0b0001111111111000,
            0b0011111111111100,
            0b0111111111111110,
            0b1111111111111111,
            0b1111111111111111,
            0b1111111111111111, 
            0b1111111111111111,
            0b1111111111111111, 
            0b1111111111111111,
            0b1111111111111111,
            0b1111111111111111,
            0b0111111111111110,
            0b0011111111111100,
            0b0001111111111000, 
            0b0000011111100000
    }; 
    
    const char line16[]= {
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	MEDIUM_RED,
	MEDIUM_RED,
	MEDIUM_RED,
	MEDIUM_RED,
	MEDIUM_RED,
        MEDIUM_RED,
	MEDIUM_RED,
	MEDIUM_RED,
	MEDIUM_RED,
	MEDIUM_RED,
	DARK_RED,
	DARK_RED,
	DARK_RED
    };
    
    
    const unsigned int sprite8[] = {
            0b0000000000000000, 
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000110000000,
            0b0000011111100000,
            0b0000111111110000,
            0b0000111111110000,
            0b0000111111110000,
            0b0000111111110000,
            0b0000011111100000,
            0b0000000110000000,
            0b0000000000000000,
            0b0000000000000000,
            0b0000000000000000, 
            0b0000000000000000
    }; 
    
    const char line8[]= {
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	LIGHT_RED,
	MEDIUM_RED,
	MEDIUM_RED,
        MEDIUM_RED,
	MEDIUM_RED,
	DARK_RED,
	DARK_RED,
	DARK_RED,
	DARK_RED,
	DARK_RED,
	DARK_RED
    };
        
   
    VDP.setSprite(BALL_SPRITE, VDP.addPattern(sprite8), VDP.addColorLine(line8) );
    
    //Valores são armazenados em coordenadas de calculo (diferente das coordenadas da tela)
    Ball.x = 30 << COORD_SHIFT;
    Ball.y = 30 << COORD_SHIFT;
    Ball.r = 4 << COORD_SHIFT;
}


//desenha a bola 
void ballDraw() {
    
   VDP.moveSprite(BALL_SPRITE, (Ball.x >> COORD_SHIFT)-8, (Ball.y >> COORD_SHIFT)-8); 
}

void ballSetSpeedAngle(t_ball *Ball, int speed, int angle) {
    //calcular vx, vy, hmvx, hmvy;
    float a;
    float s = speed;
    a = angle;
    a = a*M_PI/180.0;
    Ball->vx = cos(a)*s; 
    Ball->vy = sin(a)*s; 
    
    Ball->hmvx = (Ball->vx > 0) ? ((Ball->vx))/2: ((-Ball->vx))/2;
    Ball->hmvy = (Ball->vy > 0) ? ((Ball->vy))/2: ((-Ball->vy))/2;
    
    Ball->speed = speed;
    Ball->angle = angle;
}

void ballSetSpeed(t_ball *Ball, int speed) {
    ballSetSpeedAngle(Ball, speed, Ball->angle);
}


void ballSetVxVy(t_ball *Ball, int vx, int vy) {
    Ball->vx = vx;
    Ball->vy = vy;
    
    Ball->hmvx = (Ball->vx > 0) ? ((Ball->vx))/2: ((-Ball->vx))/2;
    Ball->hmvy = (Ball->vy > 0) ? ((Ball->vy))/2: ((-Ball->vy))/2;
}