#ifndef PADDLE_H
#define PADDLE_H

#define PADDLES_QTY 2

#define PADDLE_SPEED_1 6
#define PADDLE_SPEED_2 18

#define PADDLE_UP    0b00000001
#define PADDLE_DOWN  0b00000010
#define PADDLE_FRONT 0b00000100
#define PADDLE_BACK  0b00001000
#define PADDLE_SHOOT 0b00010000

#define PADDLE_LAUNCH_ARROW_DIST 4
#define PADDLE_LAUNCH_ARROW_SIZE 15

#include "ball.h"


extern unsigned char paddleLaunching;


typedef struct {
    int x, y;
    int spriteId;
    int size;
    int v;
    int launchAng;
    unsigned char tilt;
} t_paddle;


struct t_paddles {
    void (*setup)();
    void (*setPaddle)(int id, int x, int y);
    void (*draw)();
    t_paddle* (*getPaddle)(int id);
    int (*ballCollided)(int paddleId, t_ball *Ball);
    void (*onInput)(const char commandPlayer1, const char commandPlayer2);
    void (*setLaunching)(unsigned char l);
};

extern const struct t_paddles Paddles;

#endif
