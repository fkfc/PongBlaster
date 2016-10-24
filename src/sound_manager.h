#ifndef sound_manager_H
#define sound_manager_H

#define SOUND_MANAGER_BUFFER_SIZE 10

#define SOUND_MANAGER_CHANNEL_A 0
#define SOUND_MANAGER_CHANNEL_B 1
#define SOUND_MANAGER_CHANNEL_C 2

void soundManagerIterate();

typedef struct {
    void (*setup)();
    void (*clear)();
    void (*iterate)();
    void (*play)(unsigned char channel, const int* buffer, unsigned char nnotes);
} t_soundManager;

extern const t_soundManager SoundManager;

#endif
