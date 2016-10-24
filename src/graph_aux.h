#ifndef GRAPH_AUX_H
#define GRAPH_AUX_H

#include <types.h>

#define SCREEN_W  256
#define SCREEN_H 212

//começo da Page 3 em SCREEN 5
//#define BASE_VRAM_ADDR 0x18000
#define BASE_VRAM_ADDR 0x9000
#define PATTERNS_QTY 32
#define COLORLINES_QTY 32
#define SPRITES_QTY 32


typedef struct {
    int pattern;
    int color;
} t_sprite;



struct t_vdp_aux {

    //carrega um pattern na vram em patternNumber    
    void (*loadPattern)(int patternNumber, unsigned int *patternData);

    //copia as uma colorLine (cores de sprite) para a vram
    void (*loadColorLine)(int colorLineNumber, const char *colorData);
    
    //seta os atributos de um sprite: pattern e linesColors
    void (*setSprite)(int id, int pattern, int color);

    void (*setSpritePattern)(int id, int newPattern);

    int (*getSpritePattern)(int idSprite);

    void (*moveSprite)(int id, int x, int y);

    //retorna ponteiro para o array do color line
    char* (*getColorLine)(int colorLineNumber);
    
    //adiciona um novo pattern na VRAM, retora o id
    int (*addPattern)(unsigned int *patternData);

    //adiciona um novo colorLine na VRAM, retora o id
    int (*addColorLine)(const char *colorData);

    
};

extern const struct t_vdp_aux VDP;







#endif
