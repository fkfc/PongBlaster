#ifndef BULLET_H
#define BULLET_H

#define BULLET_PER_PADDLE 3
#define BULLET_TOTAL 6
#define BULLET_SPEED 4

#include <types.h>


typedef struct {
    int x;
    int y;
} t_bullet;




void bulletSetup();
void bulletReset();
void bulletDraw();
void bulletShoot(char paddleId);
unsigned char bulletHit(); //calcula colisao

extern t_bullet Bullet[BULLET_TOTAL];
extern char triggerEnabled[2];
//extern unsigned char bullet_lastP1;

#endif

