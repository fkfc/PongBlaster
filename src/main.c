#include <dos2.h>
#include <VDPgraph2.h>
#include <mem.h>
#include <types.h>
#include <stdio.h>
#include <stdlib.h>
#include "graph_aux.h"
#include "paddle.h"
#include "defines.h"
#include "ball.h"
#include <conio.h> //avelino's
#include "stars.h"
#include "bullet.h"
#include "placar.h"
#include "joystick.h"
#include "sincos.h"
#include "explosion.h"
#include "psg.h"
#include "title_screen.h"
#include "sound_manager.h"

//VEL_BOLA/PREC_BOLA = pixels/refresh
//#define VEL_BOLA 3

const unsigned int  PADDLE_HIT_SOUND[] = { PSG_A4 };
const unsigned char PADDLE_HIT_SOUND_SIZE = 1;

const unsigned int  BALL_HIT_SOUND[] = { PSG_G3 };
const unsigned char BALL_HIT_SOUND_SIZE = 1;

const unsigned int  GAME_START_SOUND[] = { PSG_A3, 0, 0, PSG_A3, 0, 0, PSG_E5, PSG_E5 };
const unsigned char GAME_START_SOUND_SIZE = 8;

int main(char **argv, int argc)
{
 int numPlayers;   
 unsigned char ia = 3;   //bool ia on/off
 unsigned char k1, k2;
 unsigned char j1, j2;
 
 unsigned char commandPlayer1, commandPlayer2;
 int paddle1_x, paddle2_x;
 int SCREEN_W_SHIFTED = SCREEN_W << COORD_SHIFT;
 int PLAY_AREA_H_SHIFTED = PLAY_AREA_H << COORD_SHIFT;
 unsigned char i;
 unsigned char pad2y; //var temporaria para IA desviar de tiro
 unsigned char bullety; //var temporaria para IA desviar de tiro
 unsigned int counter;
 
 unsigned int GOAL_LINE_1_SHIFTED = 10 << COORD_SHIFT;
 unsigned int GOAL_LINE_2_SHIFTED = (SCREEN_W - 10) << COORD_SHIFT;
 
 unsigned char hit;

 t_paddle *p1, *p2;
 
 if ( vMSX() < 2 ) { // only MSX2 and above
     puts("Only for MSX2 and above :(\r\n");
     return 0;
 }
 /*
 if (argc > 0) {
     if (argv[0][0] == '1') ia = 1;
     if (argv[0][0] == '2') ia = 0;
 }*/ 
 
 
 Save_VDP();		// Save VDP internals 
 SetScreen5();
 Sprites_On();
 EnableScreen();
 
 SetColors( WHITE, BLACK, BLACK );
 SetBorderColor(BLACK);
 ClearScreen();
 
 
 while (numPlayers = showTitleScreen(), numPlayers != 0) {
    ResetSprites();
    Sprites_16();
    
    if (numPlayers == 1) ia = 1;
    else ia = 0;
        
    
    //carrega sprites
    Paddles.setup();
    SoundManager.setup();
    Explosion.setup();
    ballSetup();
    starsSetup();
    bulletSetup();
    Placar.setup();
    


    //pos inicial da bola
    Ball.x = (SCREEN_W_SHIFTED)/2; 
    Ball.y = (PLAY_AREA_H_SHIFTED)/2; 
    
    
    //paddle 2 pode ser IA
    p1 = Paddles.getPaddle(0);
    p2 = Paddles.getPaddle(1);
    
    paddle1_x = Paddles.getPaddle(0)->x + (8 << COORD_SHIFT);
    paddle2_x = Paddles.getPaddle(1)->x - (8 << COORD_SHIFT);
    
    
    //play area
    LINE(0,  0, SCREEN_W-1,  0, DARK_YELLOW, LOGICAL_IMP );
    LINE(0,  PLAY_AREA_H-1, SCREEN_W-1,  PLAY_AREA_H-1, DARK_YELLOW, LOGICAL_IMP );
    
    
    Placar.draw();
    
    Sprites_On(); // Activate sprites
    
    
    
    //trajetoria inicial da bola
    ballSetSpeedAngle(&Ball, ((rand()%2)?1:-1)*BALL_INIT_SPEED, BALL_INIT_ANGLE);
    
    
    //show their starting positions
    ballDraw();
    Paddles.draw();
    
    //start game:  "3 2 1 go" sound
    SoundManager.play(SOUND_MANAGER_CHANNEL_A, GAME_START_SOUND, GAME_START_SOUND_SIZE);
    for (i = 0; i < GAME_START_SOUND_SIZE; i++) {
        SoundManager.iterate();
        for (counter = 0; counter < 15000; counter++);
    }

    
    
    
    //main game loop
    while(keyboard_read_7() != KB_ESC) { // wait for ESC  
        //SoundManager.iterate();
        soundManagerIterate();
        
        k1 = keyboard_read();	//player1
        k2 = keyboard_read_3(); //player2
        
        j1 = joystick_1_read();
        j2 = joystick_2_read();

        
        //IA em player2
        if (ia) {
            //persegue a bola
            if (p2->y < Ball.y) j2 = JOY_DOWN;
            if (p2->y > Ball.y) j2 = JOY_UP;
            
            //foge de tiro       
            for (i = 0; i < BULLET_PER_PADDLE; i++) {
                    pad2y = (p2->y >> COORD_SHIFT); //coloca paddle2.y em coordenadas de pixel
                    if (Bullet[i].x > 180) {
                        bullety = Bullet[i].y;
                        if (pad2y > bullety) { //padle está abaixo do tiro
                            if ((pad2y - bullety) < 15) j2 = JOY_DOWN;
                        } else { //paddle está acima
                            if ((bullety - pad2y) < 15) j2 = JOY_UP;
                        }
                    }
            }
            
            //IA lançando bola
            if (paddleLaunching == 2) {
                switch (rand() % 9) {
                    case 0: 
                    case 1:
                    case 2:    
                    case 3:
                        j2 += JOY_LEFT;
                        break;
                    case 4:
                    case 5:
                    case 6:    
                    case 7:
                        j2 += JOY_RIGHT;
                        break;     
                    case 8:   
                        j2 += JOY_TRIG_A;
                        break;
                }
            } else {
                if (p2->y - p1->y < 3) j2 += JOY_TRIG_A;
            }
        }
        
        
        
        //input: transforma o input em comando
        //player 1
        commandPlayer1 = 0;
        if (k1 != 0) { //teclado
            if (k1 & KB_UP) commandPlayer1 += PADDLE_UP;
            else if (k1 & KB_DOWN) commandPlayer1 += PADDLE_DOWN;
            if (k1 & KB_LEFT) commandPlayer1 += PADDLE_BACK;
            else if (k1 & KB_RIGHT) commandPlayer1 += PADDLE_FRONT;
            if (k1 & KB_SPACE) commandPlayer1 += PADDLE_SHOOT;
        }
        if (j1 != JOY_IDLE) { //joystick
            if (j1 & JOY_UP) commandPlayer1 += PADDLE_UP;
            else if (j1 & JOY_DOWN) commandPlayer1 += PADDLE_DOWN;
            if (j1 & JOY_LEFT) commandPlayer1 += PADDLE_BACK;
            else if (j1 & JOY_RIGHT) commandPlayer1 += PADDLE_FRONT;
            if (j1 & JOY_TRIG_A) commandPlayer1 += PADDLE_SHOOT;
        }
        
        //player2
        commandPlayer2 = 0;
        if (k2 != 0) { //teclado
            if (k2 & KB_E) commandPlayer2 += PADDLE_UP;
            else if (k2 & KB_D) commandPlayer2 += PADDLE_DOWN;
            if (k2 & KB_J) commandPlayer2 += PADDLE_BACK;
            else if (k2 & KB_H) commandPlayer2 += PADDLE_FRONT;
            
            if (k2 & KB_F) commandPlayer2 += PADDLE_SHOOT;
        }
        if (j2 != JOY_IDLE) { //joystick
            if (j2 & JOY_UP) commandPlayer2 += PADDLE_UP;
            else if (j2 & JOY_DOWN) commandPlayer2 += PADDLE_DOWN;
            if (j2 & JOY_LEFT) commandPlayer2 += PADDLE_BACK;
            else if (j2 & JOY_RIGHT) commandPlayer2 += PADDLE_FRONT;
            if (j2 & JOY_TRIG_A) commandPlayer2 += PADDLE_SHOOT;
        }
        
        //executa comandos
        Paddles.onInput(commandPlayer1, commandPlayer2);
        
        //bullet triggers
        if (!paddleLaunching) { //shoot
            if (commandPlayer1 & PADDLE_SHOOT) bulletShoot(0);
            else triggerEnabled[0] = 1;
            if (commandPlayer2 & PADDLE_SHOOT) bulletShoot(1);
            else triggerEnabled[1] = 1;
        } else {
            if (paddleLaunching == 1) { //player1 lançando a bola
                if (commandPlayer1 & PADDLE_SHOOT) {
                    ballSetSpeedAngle(
                        &Ball, 
                        BALL_INIT_SPEED,
                        (Paddles.getPaddle(0)->launchAng+1)*20 - 90);
                    Paddles.setLaunching(0);
                }
            } else { //player2 lançando a bola
                if (commandPlayer2 & PADDLE_SHOOT) {
                    ballSetSpeedAngle(
                        &Ball, 
                        BALL_INIT_SPEED,
                        -90 - (Paddles.getPaddle(1)->launchAng+1)*20);
                    Paddles.setLaunching(0);
                }
            }
        }
        
        
        
        
        if ( Paddles.ballCollided(0, &Ball) || Paddles.ballCollided(1, &Ball) ) {
            //aumenta a velocidade da bola
            SoundManager.play(SOUND_MANAGER_CHANNEL_A, PADDLE_HIT_SOUND, PADDLE_HIT_SOUND_SIZE);
            ballSetVxVy(&Ball, Ball.vx*1.1, Ball.vy*1.1);
        }
        
        
            
        //Move a bola
        if (paddleLaunching == 0) {
            Ball.x += Ball.vx; 
            Ball.y += Ball.vy;
        } else {
            if (paddleLaunching == 1) {
                Ball.x = Paddles.getPaddle(0)->x + Ball.r + (PADDLE_LAUNCH_ARROW_DIST << COORD_SHIFT);
                Ball.y = Paddles.getPaddle(0)->y;
            } else {
                Ball.x = Paddles.getPaddle(1)->x - Ball.r - (PADDLE_LAUNCH_ARROW_DIST << COORD_SHIFT);
                Ball.y = Paddles.getPaddle(1)->y;
            }
            
        }
        
        
        ballDraw();
        starsDraw(); 
        bulletDraw();
        
        
        //quica a bola nas bordas da tela
        if ((Ball.y - Ball.r <= 0) || 
            (Ball.y + Ball.r >= PLAY_AREA_H_SHIFTED )) {
                    Ball.vy = - Ball.vy;
                    SoundManager.play(SOUND_MANAGER_CHANNEL_A, BALL_HIT_SOUND, BALL_HIT_SOUND_SIZE);
        }
        
        
        
        
        //marcou ponto
        if (Ball.x < GOAL_LINE_1_SHIFTED) { //gol
            Placar.goal(2);
            Paddles.setLaunching(1);

            bulletReset();
            //Placar.draw();
            
        } else if (Ball.x > GOAL_LINE_2_SHIFTED) { //gol
            Placar.goal(1); 
            Paddles.setLaunching(2);
            

            bulletReset();
            //Placar.draw();

        } else { //hit
            hit = bulletHit();
            if (hit) {
                if (hit == 1) {
                    Explosion.show((Paddles.getPaddle(1)->x >> COORD_SHIFT), (Paddles.getPaddle(1)->y >> COORD_SHIFT));
                    Placar.inc(1);
                    Paddles.setLaunching(2);
                }
                if (hit == 2) {
                    Explosion.show((Paddles.getPaddle(0)->x >> COORD_SHIFT), (Paddles.getPaddle(0)->y >> COORD_SHIFT));
                    Placar.inc(2);
                    Paddles.setLaunching(1);
                }
                

                bulletReset();
                Placar.draw();
            }
        }

        
        

        // to slow down MSX
        //_ei_halt();
    };
        
    //clear the sound buffer and then silence all channels
    SoundManager.clear();
    soundManagerIterate();
    
 } 
 
 SetColors( WHITE, BLACK, BLACK );
 
 //ClearKeyBuffer();
 SetScreen0(); 
 Restore_VDP();		// Restore VDP internals

 return 0;
}
