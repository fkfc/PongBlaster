#include "sound_manager.h"
#include "psg.h"
#include <types.h>

int soundManagerIterator;
unsigned int soundManagerBuffer[SOUND_MANAGER_BUFFER_SIZE][3];



void soundManagerClear() {
    int i;
    soundManagerIterator = 0;
    for (i = 0; i < SOUND_MANAGER_BUFFER_SIZE; i++) {
        soundManagerBuffer[i][0] = 0;
        soundManagerBuffer[i][1] = 0;
        soundManagerBuffer[i][2] = 0;
    }
}

void soundManagerSetup() {
    psg_write( 7, 0b10111000 ); // mixer. Enable channels
    psg_write( 8, 0 ); // volume ch 1
    psg_write( 9, 0 ); // volume ch 2
    psg_write(10, 0 ); // volume ch 3
    soundManagerClear();
}


void soundManagerIterate() {
    unsigned char channel;
    unsigned int tone;
    unsigned char reg = 0;

    for (channel = 0; channel < 3; channel++) {
        tone = soundManagerBuffer[soundManagerIterator][channel];
        soundManagerBuffer[soundManagerIterator][channel] = 0;
        if (tone == 0) {
            psg_write( channel+8, 0 ); // mute
            reg += 2;
        } else {
            psg_write( reg++, (unsigned char)tone ); // freq. low
            psg_write( reg++, (unsigned char)(tone >> 8) ); // freq. high
            psg_write( channel+8, 15 ); // play
        }
    }
    
    soundManagerIterator++;
    if (soundManagerIterator == SOUND_MANAGER_BUFFER_SIZE) soundManagerIterator = 0;
}


void soundManagerPlay(unsigned char channel, const int* buffer, unsigned char nnotes) {
    unsigned char p;
    unsigned char i;
    
    p = soundManagerIterator;
    for (i = 0; i < nnotes; i++) {
        soundManagerBuffer[p][channel] = buffer[i];
        p++;
        if (p == SOUND_MANAGER_BUFFER_SIZE) p = 0;
    }
}

const t_soundManager SoundManager = {
    .setup = soundManagerSetup,
    .clear = soundManagerClear,
    .iterate = soundManagerIterate,
    .play = soundManagerPlay
};
