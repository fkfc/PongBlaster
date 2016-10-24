#include "paddle.h"
#include "graph_aux.h"
#include "defines.h"
#include <types.h>
#include <VDPgraph2.h>
#include "sincos.h"


t_paddle paddle_paddles[2];
unsigned char paddleLaunching;

int areaLimitY1;
int areaLimitY2;

//step = pi/9: [-pi+pi/9 .. pi-pi/9]
const int precalc_15_sin[] = { -13, -12, -7, -4,  4, 7, 12, 13 };
const int precalc_15_cos[] = {  5,  9,  13, 15, 15, 13, 9, 5 };
//const int precalc_10_sin[] = { -9, -8, -5, -2,  2, 5, 8, 9 };
//const int precalc_10_cos[] = {  3,  6,  9, 10, 10, 9, 6, 3 };

void setup() {
    
    const unsigned int pattern1[] = {
            0b0000001111000000,
            0b0000001111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000011000000,
            0b0000000011000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000001111000000,
            0b0000001111000000
    };   
    
    const unsigned int pattern1u[] = {
            0b0000011110000000,
            0b0000011110000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000011000000,
            0b0000000011000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000111100000,
            0b0000000111100000
    };
    
    const unsigned int pattern1d[] = {
            0b0000000111100000,
            0b0000000111100000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000011000000,
            0b0000000011000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000011110000000,
            0b0000011110000000
    }; 
    
    const unsigned int pattern2[] = {
            0b0000000111100000,
            0b0000000111100000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000110000000,
            0b0000000110000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000111100000,
            0b0000000111100000
    };
    
    const unsigned int pattern2u[] = {
            0b0000000011110000,
            0b0000000011110000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000110000000,
            0b0000000110000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000001111000000,
            0b0000001111000000
    };
    
    const unsigned int pattern2d[] = {
            0b0000001111000000,
            0b0000001111000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000001110000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000110000000,
            0b0000000110000000,
            0b0000000111000000,
            0b0000000111000000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000011100000,
            0b0000000011110000,
            0b0000000011110000
    };
    
    
    const unsigned int patternThruster[] = {
            0b0000000100000000,
            0b0000000000000000,
            0b0000000100000000,
            0b0000000001000000,
            0b0000000010000000,
            0b0000000000000000,
            0b0000000100000000,
            0b0000000010000000,
            0b0000000010000000,
            0b0000000100000000,
            0b0000000010000000,
            0b0000000100000000,
            0b0000000010000000,
            0b0000000100000000,
            0b0000000000000000,
            0b0000000100000000
    };
    
    const char colors1[]= {
	DARK_BLUE,
	DARK_BLUE,
	DARK_BLUE,
	LIGHT_BLUE,
	LIGHT_BLUE,
	LIGHT_BLUE,
	LIGHT_BLUE,
	WHITE,
        WHITE,
	LIGHT_BLUE,
	LIGHT_BLUE,
	LIGHT_BLUE,
	LIGHT_BLUE,
	DARK_BLUE,
	DARK_BLUE,
	DARK_BLUE
    };
    
    
    const char colors2[]= {
	DARK_GREEN,
	DARK_GREEN,
	DARK_GREEN,
	LIGHT_GREEN,
	LIGHT_GREEN,
	LIGHT_GREEN,
	LIGHT_GREEN,
	WHITE,
        WHITE,
	LIGHT_GREEN,
	LIGHT_GREEN,
	LIGHT_GREEN,
	LIGHT_GREEN,
	DARK_GREEN,
	DARK_GREEN,
	DARK_GREEN
    };
    
    const char colorsThruster[]= {
	DARK_BLUE,
	LIGHT_BLUE,
	DARK_BLUE,
	DARK_BLUE,
	LIGHT_BLUE,
	DARK_BLUE,
	LIGHT_BLUE,
	LIGHT_BLUE,
        LIGHT_BLUE,
	LIGHT_BLUE,
	DARK_BLUE,
	LIGHT_BLUE,
	DARK_BLUE,
	DARK_BLUE,
	LIGHT_BLUE,
	DARK_BLUE
    };
    
    VDP.setSprite(PADDLE1_THRUSTER, VDP.addPattern(patternThruster), VDP.addColorLine(colorsThruster) );
    VDP.setSprite(PADDLE2_THRUSTER, VDP.addPattern(patternThruster), VDP.addColorLine(colorsThruster) );

        
    VDP.setSprite(PADDLE1_SPRITE, VDP.addPattern(pattern1), VDP.addColorLine(colors1) );
    VDP.setSprite(PADDLE1_SPRITE_UP, VDP.addPattern(pattern1u), VDP.addColorLine(colors1) );
    VDP.setSprite(PADDLE1_SPRITE_DOWN, VDP.addPattern(pattern1d), VDP.addColorLine(colors1) );
    
    VDP.setSprite(PADDLE2_SPRITE, VDP.addPattern(pattern2), VDP.addColorLine(colors2) );
    VDP.setSprite(PADDLE2_SPRITE_UP, VDP.addPattern(pattern2u), VDP.addColorLine(colors2) );
    VDP.setSprite(PADDLE2_SPRITE_DOWN, VDP.addPattern(pattern2d), VDP.addColorLine(colors2) );
    
    
    Paddles.getPaddle(0)->spriteId = PADDLE1_SPRITE;
    Paddles.getPaddle(0)->x = 20 << COORD_SHIFT;
    Paddles.getPaddle(0)->y = PLAY_AREA_H/2 << COORD_SHIFT;
    Paddles.getPaddle(0)->size = 16 << COORD_SHIFT;
    Paddles.getPaddle(0)->launchAng = 4;
    Paddles.getPaddle(0)->tilt = 0;
    
    Paddles.getPaddle(1)->spriteId = PADDLE2_SPRITE;
    Paddles.getPaddle(1)->x = 236 << COORD_SHIFT;
    Paddles.getPaddle(1)->y = PLAY_AREA_H/2 << COORD_SHIFT;
    Paddles.getPaddle(1)->size = 16 << COORD_SHIFT;
    Paddles.getPaddle(1)->launchAng = 4;
    Paddles.getPaddle(1)->tilt = 0;
    
    paddleLaunching = 0;
    
    areaLimitY1 = (8 << COORD_SHIFT);
    areaLimitY2 = (PLAY_AREA_H - 8) << COORD_SHIFT;

}


void onInput(const char commandPlayer1, const char commandPlayer2) {
    int dy1, dy2;
    int newPos1, newPos2;

    dy1 = 0;
    dy2 = 0;
    
    //movimento
    if (commandPlayer1 & PADDLE_UP) dy1 = -PADDLE_SPEED_2;
    else if (commandPlayer1 & PADDLE_DOWN) dy1 = PADDLE_SPEED_2;
    
    if (commandPlayer2 & PADDLE_UP) dy2 = -PADDLE_SPEED_2; 
    else if (commandPlayer2 & PADDLE_DOWN) dy2 = PADDLE_SPEED_2; 
    
    if (paddleLaunching == 1) { //player1 lançando a bola
        
        if (commandPlayer1 & (PADDLE_BACK | PADDLE_FRONT | PADDLE_UP | PADDLE_DOWN) ) {
            //apaga linha antiga
            LINE((paddle_paddles[0].x >> COORD_SHIFT) + PADDLE_LAUNCH_ARROW_DIST + (Ball.r >> COORD_SHIFT), 
                    paddle_paddles[0].y >> COORD_SHIFT,
                    (paddle_paddles[0].x >> COORD_SHIFT) + PADDLE_LAUNCH_ARROW_DIST + (Ball.r >> COORD_SHIFT) + precalc_15_cos[paddle_paddles[0].launchAng],
                    (paddle_paddles[0].y >> COORD_SHIFT) + precalc_15_sin[paddle_paddles[0].launchAng], 
                    BLACK, LOGICAL_IMP);
        }
        
        if (commandPlayer1 & PADDLE_BACK) {
            paddle_paddles[0].launchAng--;
            if (paddle_paddles[0].launchAng < 0) paddle_paddles[0].launchAng = 0;
        } else if (commandPlayer1 & PADDLE_FRONT) {
            paddle_paddles[0].launchAng++;
            if (paddle_paddles[0].launchAng > 7) paddle_paddles[0].launchAng = 7;
        }

    } else { //inclinação do paddle1
        if (commandPlayer1 & PADDLE_BACK) {
            VDP.moveSprite(paddle_paddles[0].spriteId, 0, 217); //esconde sprite antigo
            paddle_paddles[0].spriteId = PADDLE1_SPRITE_UP;
            paddle_paddles[0].tilt = PADDLE_BACK;
        } else if (commandPlayer1 & PADDLE_FRONT) {
            VDP.moveSprite(paddle_paddles[0].spriteId, 0, 217); //esconde sprite antigo
            paddle_paddles[0].spriteId = PADDLE1_SPRITE_DOWN;
            paddle_paddles[0].tilt = PADDLE_FRONT;
        } else if (paddle_paddles[0].spriteId != PADDLE1_SPRITE) {
            VDP.moveSprite(paddle_paddles[0].spriteId, 0, 217); //esconde sprite antigo
            paddle_paddles[0].spriteId = PADDLE1_SPRITE;
            paddle_paddles[0].tilt = 0;
        }
    }   
    
    if (paddleLaunching == 2) { //player2 lançando a bola
        
        if (commandPlayer2 & (PADDLE_BACK | PADDLE_FRONT | PADDLE_UP | PADDLE_DOWN) ) {
            //apaga linha antiga
            LINE((paddle_paddles[1].x >> COORD_SHIFT) - PADDLE_LAUNCH_ARROW_DIST - (Ball.r >> COORD_SHIFT), 
                    paddle_paddles[1].y >> COORD_SHIFT,
                    (paddle_paddles[1].x >> COORD_SHIFT) - PADDLE_LAUNCH_ARROW_DIST - (Ball.r >> COORD_SHIFT) - precalc_15_cos[paddle_paddles[1].launchAng],
                    (paddle_paddles[1].y >> COORD_SHIFT) + precalc_15_sin[paddle_paddles[1].launchAng], 
                    BLACK, LOGICAL_IMP);
        }
        
        if (commandPlayer2 & PADDLE_BACK) {
            paddle_paddles[1].launchAng++;
            if (paddle_paddles[1].launchAng > 7) paddle_paddles[1].launchAng = 7;
        } else if (commandPlayer2 & PADDLE_FRONT) {
            paddle_paddles[1].launchAng--;
            if (paddle_paddles[1].launchAng < 0) paddle_paddles[1].launchAng = 0;
        }
        
    } else { //inclinação do paddle2
        if (commandPlayer2 & PADDLE_BACK) {
            VDP.moveSprite(paddle_paddles[1].spriteId, 0, 217); //esconde sprite antigo
            paddle_paddles[1].spriteId = PADDLE2_SPRITE_UP;
            paddle_paddles[1].tilt = PADDLE_BACK;
        } else if (commandPlayer2 & PADDLE_FRONT) {
            VDP.moveSprite(paddle_paddles[1].spriteId, 0, 217); //esconde sprite antigo
            paddle_paddles[1].spriteId = PADDLE2_SPRITE_DOWN;
            paddle_paddles[1].tilt = PADDLE_FRONT;
        } else if (paddle_paddles[1].spriteId != PADDLE2_SPRITE) {
            VDP.moveSprite(paddle_paddles[1].spriteId, 0, 217); //esconde sprite antigo
            paddle_paddles[1].spriteId = PADDLE2_SPRITE;
            paddle_paddles[1].tilt = 0;
        }
    } 
    
    
    //Keep both paddles inside the play area
    newPos1 = paddle_paddles[0].y + dy1;
    if (newPos1 > areaLimitY1 && newPos1 < areaLimitY2) {
        paddle_paddles[0].y = newPos1;
        paddle_paddles[0].v = dy1;
    }
    
    newPos2 = paddle_paddles[1].y + dy2;
    if (newPos2 > areaLimitY1 && newPos2 < areaLimitY2) {
        paddle_paddles[1].y = newPos2;
        paddle_paddles[1].v = dy2;
    }
    
    
    //Draw
    Paddles.draw();
    
}


void setPaddle(int id, int x, int y) {
    t_paddle *paddle;
    
    paddle = Paddles.getPaddle(id);
   
    //mantem o paddle na tela
    if(y <= paddle->size/2) y = paddle->size/2;
    else if( (y >= PLAY_AREA_H) << COORD_SHIFT - paddle->size/2) y = (PLAY_AREA_H << COORD_SHIFT) - paddle->size/2;

    paddle->x = x;
    paddle->y = y;
    
}

t_paddle* getPaddle(int id) {
    return &(paddle_paddles[id]);
}

//x,y ball center
//r ball radius
int ballCollided(int paddleId, t_ball *Ball) {
    int x, y, vx, vy; //centro e velocidades da bola
    int yp, gy, xp, gx, s;
    t_paddle *paddle;
    
    paddle = Paddles.getPaddle(paddleId);
    xp = paddle->x;
    yp = paddle->y;
    s = paddle->size/2;
    x = Ball->x;
    y = Ball->y;
    vx = Ball->vx;
    vy = Ball->vy;
    
    
    //gx e gy = diferenciais de distancia entre o paddle a bola
    if (xp > x) gx = xp-x;
    else gx = x - xp;

    if (yp > y) gy = yp-y;
    else gy = y - yp;


    gx = gx - Ball->r - Ball->hmvx;
    gy = gy - ( s + Ball->r) - Ball->hmvy;
    
    if (gx < 0 && gy < 0) { //colidiu 
        //sempre inverte no eixo x (bola volta ao adversario)
        if (xp < x) { //bola à direita da raquete. vx positivo
            Ball->vx = (vx > 0) ? vx : -vx;
        } else { //bola à esquerda da raquete. vx negativo
            Ball->vx = (vx < 0) ? vx : -vx;
        }
        if (gy < gx) { //predominantemente horizontal
            //(d)Efeitos:
            if (paddle->tilt == 0) { //paddle reto, efeitos de acordo com a velocidade do paddle
                if (paddle->v*vy > 0) { 
                    Ball->vy =  vy*0.81;
                } else if (paddle->v*vy < 0) {
                    Ball->vy = Ball->vy*1.2;
                } 
            } else { //paddle inclinado
                if (paddle->tilt == PADDLE_BACK) { //inclinado para cima. bola sai subindo
                    if (vy > 0) { //bola veio descendo
                        Ball->vy = (vx < 0)? vx : -vx;
                        Ball->vx = (Ball->vx*vy < 0)? -vy : vy;
                        /*Ball->vy = -vy*0.81;
                        Ball->vx = Ball->vx*1.3;*/
                    } else { //bola veio subindo
                        Ball->vy = Ball->vy*1.5;
                        Ball->vx = Ball->vx*0.5;
                    }
                } else { //inclinado para baixo. bola sai descendo
                    if (vy < 0) { //bola veio subindo
                        Ball->vy = (vx > 0)? vx : -vx;
                        Ball->vx = (Ball->vx*vy < 0)? -vy : vy;
                         /*
                        Ball->vy = -vy*0.81;
                        Ball->vx = Ball->vx*1.3;
                        */
                    } else { //bola veio descendo
                        Ball->vy = Ball->vy*1.5;
                        Ball->vx = Ball->vx*0.5;
                        /*
                        Ball->vy = vy*1.51;
                        Ball->vx = Ball->vx*0.7;
                        */
                    }
                }
            }
        } else { //vertical! Verificar angulo de incidencia, sempre vai pra baixo ou cima (dependendo de onde a bola vier)
            if (yp < y) { //paddle está em cima da bola, bola desce (vy positivo)
                Ball->vy = (vy > 0) ? vy : -vy;
            } else { //paddle está embaixo da bola, bola sobe (vy negativo)
                Ball->vy = (vy < 0) ? vy : -vy;
            }
        }
        return 1;
    } else { //não colidiu
        return 0;
    }
}


void draw() {
   
    
   VDP.moveSprite(paddle_paddles[0].spriteId, 
                   (paddle_paddles[0].x >> COORD_SHIFT) - 8, 
                   (paddle_paddles[0].y >> COORD_SHIFT) - 8) ;
                   
   VDP.moveSprite(paddle_paddles[1].spriteId,  
                   (paddle_paddles[1].x >> COORD_SHIFT) - 8, 
                   (paddle_paddles[1].y >> COORD_SHIFT) - 8) ;            
                   
   VDP.moveSprite(PADDLE1_THRUSTER,  
                   (paddle_paddles[0].x >> COORD_SHIFT) - 8, 
                   ((paddle_paddles[0].y - 3*paddle_paddles[0].v) >> COORD_SHIFT) - 8) ; 
    
   VDP.moveSprite(PADDLE2_THRUSTER,  
                   (paddle_paddles[1].x >> COORD_SHIFT) - 7, 
                   ((paddle_paddles[1].y - 3*paddle_paddles[1].v) >> COORD_SHIFT) - 8) ;
    
    //desenha as linhas de lançamento da bola
    if (paddleLaunching == 1) {
        LINE((paddle_paddles[0].x >> COORD_SHIFT) + PADDLE_LAUNCH_ARROW_DIST  + (Ball.r >> COORD_SHIFT), 
                 paddle_paddles[0].y >> COORD_SHIFT,
                 (paddle_paddles[0].x >> COORD_SHIFT) + PADDLE_LAUNCH_ARROW_DIST + (Ball.r >> COORD_SHIFT) + precalc_15_cos[paddle_paddles[0].launchAng],
                 (paddle_paddles[0].y >> COORD_SHIFT) + precalc_15_sin[paddle_paddles[0].launchAng], 
                 WHITE, LOGICAL_IMP);
    } else if (paddleLaunching == 2) {
        LINE((paddle_paddles[1].x >> COORD_SHIFT) - PADDLE_LAUNCH_ARROW_DIST - (Ball.r >> COORD_SHIFT), 
                 paddle_paddles[1].y >> COORD_SHIFT,
                 (paddle_paddles[1].x >> COORD_SHIFT) - PADDLE_LAUNCH_ARROW_DIST - (Ball.r >> COORD_SHIFT) - precalc_15_cos[paddle_paddles[1].launchAng],
                 (paddle_paddles[1].y >> COORD_SHIFT) + precalc_15_sin[paddle_paddles[1].launchAng], 
                 WHITE, LOGICAL_IMP);
    }
    
    
}

void setLaunching(unsigned char l) {       
    paddleLaunching = l;
    
    if (paddleLaunching == 0) { //esconde a linha
        LINE((paddle_paddles[0].x >> COORD_SHIFT) + PADDLE_LAUNCH_ARROW_DIST + (Ball.r >> COORD_SHIFT), 
                 paddle_paddles[0].y >> COORD_SHIFT,
                 (paddle_paddles[0].x >> COORD_SHIFT) + PADDLE_LAUNCH_ARROW_DIST + (Ball.r >> COORD_SHIFT) + precalc_15_cos[paddle_paddles[0].launchAng],
                 (paddle_paddles[0].y >> COORD_SHIFT) + precalc_15_sin[paddle_paddles[0].launchAng], 
                 BLACK, LOGICAL_IMP);
        
        LINE((paddle_paddles[1].x >> COORD_SHIFT) - PADDLE_LAUNCH_ARROW_DIST - (Ball.r >> COORD_SHIFT), 
                 paddle_paddles[1].y >> COORD_SHIFT,
                 (paddle_paddles[1].x >> COORD_SHIFT) - PADDLE_LAUNCH_ARROW_DIST - (Ball.r >> COORD_SHIFT) - precalc_15_cos[paddle_paddles[1].launchAng],
                 (paddle_paddles[1].y >> COORD_SHIFT) + precalc_15_sin[paddle_paddles[1].launchAng], 
                 BLACK, LOGICAL_IMP);
        
    } else if (paddleLaunching == 1) { //deixa o paddle reto (sem tilt)
        VDP.moveSprite(paddle_paddles[0].spriteId, 0, 217); //esconde sprite antigo
        paddle_paddles[0].spriteId = PADDLE1_SPRITE;
        paddle_paddles[0].tilt = 0;
        
        Ball.x = paddle_paddles[0].x + Ball.r + (PADDLE_LAUNCH_ARROW_DIST << COORD_SHIFT);
        Ball.y = paddle_paddles[0].y;
           
    } else if (paddleLaunching == 2) { //deixa o paddle reto (sem tilt)
        VDP.moveSprite(paddle_paddles[1].spriteId, 0, 217); //esconde sprite antigo
        paddle_paddles[1].spriteId = PADDLE2_SPRITE;
        paddle_paddles[1].tilt = 0;
        
        Ball.x = paddle_paddles[1].x - Ball.r - (PADDLE_LAUNCH_ARROW_DIST << COORD_SHIFT);
        Ball.y = paddle_paddles[1].y;
        Ball.vx = 0;
        Ball.vy = 0;
    } 
}

const struct t_paddles Paddles = {
     .setup = setup,
     .setPaddle = setPaddle,
     .draw = draw,
     .getPaddle = getPaddle,
     .ballCollided = ballCollided,
     .onInput = onInput,
     .setLaunching = setLaunching
};

