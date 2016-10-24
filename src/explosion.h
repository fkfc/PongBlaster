#ifndef EXPLOSION_H
#define EXPLOSION_H

#define EXPLOSION_ANIMATION_TIMER 5000
#define EXPLOSION_COLOR LIGHT_RED

typedef struct {
    void (*setup)();
    void (*show)(int x, int y);
    void (*hide)();
} t_explosion;

extern const t_explosion Explosion;


#endif
