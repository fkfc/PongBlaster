#include "graph_aux.h"

#include <VDPgraph2.h>
#include <mem.h>

//patterns: mapa de bits para os sprites 16 linhas de 2 bytes cada = 32bytes (0x20) por sprite
unsigned int __at (BASE_VRAM_ADDR) vramPatterns[PATTERNS_QTY*16];
//linhas de cores para os sprites, 16 bytes para cada sprite
char __at (BASE_VRAM_ADDR + 0x20*PATTERNS_QTY) vramColorLines[COLORLINES_QTY*16];

int VDP_lastPatternId = 0;
int VDP_lastColorLineId = 0;
t_sprite VDP_sprites[SPRITES_QTY];


char *getColorLine(int colorLineNumber) {
    return &(vramColorLines[16*colorLineNumber]);
}


//carrega um pattern na vram em patternNumber
void loadPattern(int patternNumber, unsigned int *patternData) {
    unsigned int *ptrP = &(vramPatterns[16*patternNumber/4]);
    memcpy((uint8_t *) ptrP, (uint8_t *) patternData, 16*2);
    SpritePattern(patternNumber, Sprite32bytes(ptrP) );
}

//copia as uma colorLine (cores de sprite) para a vram
void loadColorLine(int colorLineNumber, const char *colorData) {
    char *vramPtr = VDP.getColorLine(colorLineNumber);
    memcpy((uint8_t *) vramPtr, (uint8_t *) colorData, 16);
    
    
}
    
//adiciona um novo pattern na VRAM, retora o id
int addPattern(unsigned int *patternData) {
    int id = VDP_lastPatternId;
    VDP_lastPatternId = VDP_lastPatternId + 4;
    VDP.loadPattern(id, patternData);
    return id;
}

//adiciona um novo colorLine na VRAM, retora o id
int addColorLine(const char *colorData) {
    VDP.loadColorLine(VDP_lastColorLineId, colorData);
    return VDP_lastColorLineId++;
}

//seta os atributos de um sprite: pattern e linesColors
void setSprite(int id, int newpattern, int newcolor) {
    VDP.setSpritePattern(id, newpattern);
    VDP_sprites[id].color = newcolor;
    
    SpriteColours( id, VDP.getColorLine( newcolor ) );
}

void setSpritePattern(int id, int newPattern) {
    VDP_sprites[id].pattern = newPattern;
}

void moveSprite(int id, int x, int y) {
    SpriteAttribs(id, VDP_sprites[id].pattern, x, y );
}


int getSpritePattern(int idSprite) {
    return VDP_sprites[idSprite].pattern;
}



const struct t_vdp_aux VDP = {
     .loadPattern = loadPattern,
     .loadColorLine = loadColorLine,
     .setSprite = setSprite,
     .setSpritePattern = setSpritePattern,
     .getSpritePattern = getSpritePattern,
     .moveSprite = moveSprite,
     .getColorLine = getColorLine,
     .addPattern = addPattern,
     .addColorLine = addColorLine
};