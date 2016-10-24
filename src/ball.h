#ifndef BALL_H
#define BALL_H




typedef struct {
    int x;
    int y;
    int r;
    int vx;
    int vy;
    int hmvx; //half module vx, shifted (right)
    int hmvy; //half module vy, shifted
    int angle;
    int speed;
} t_ball;

extern t_ball Ball;


void ballSetup();
void ballDraw();
void ballSetSpeedAngle(t_ball *Ball, int speed, int angle);
void ballSetSpeed(t_ball *Ball, int speed);
void ballSetVxVy(t_ball *Ball, int vx, int vy);

#endif
