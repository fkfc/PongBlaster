#ifndef JOYSTICK_H
#define JOYSTICK_H

#define JOY_IDLE   0b10000000
#define JOY_UP     0b00000001
#define JOY_DOWN   0b00000010
#define JOY_LEFT   0b00000100
#define JOY_RIGHT  0b00001000
#define JOY_TRIG_A 0b00010000
#define JOY_TRIG_B 0b00100000

extern int joystick_1_read( void );
extern int joystick_2_read( void );

#endif
