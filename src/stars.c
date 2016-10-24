#include "stars.h"
#include <stdlib.h>
#include "sqrt.h"
#include "graph_aux.h"
#include <VDPgraph2.h>
#include "defines.h"

int stars[STARS_PARALLAX_LEVELS][STARS_QTY_PER_LEVEL][2];
unsigned char stars_count[STARS_PARALLAX_LEVELS];
const int colors[] = {WHITE, GRAY, DARK_RED};

void starsSetup() {
    int perline, x, y, line, level, col, color;
    
    perline = sqrt(STARS_QTY_PER_LEVEL);
    for (level = 0; level < STARS_PARALLAX_LEVELS; level++) {
        stars_count[level] = 0;
        color = colors[level];
        for (line = 0; line < perline; line++) {
            for (col = 0; col < perline; col++) {    
                y = 1+ line*PLAY_AREA_H/(perline) + (rand() % ((PLAY_AREA_H-2)/(perline))) ;
                x = col*SCREEN_W/(perline) + (rand() % SCREEN_W/(perline));
                stars[level][line*perline + col][0] = x;
                stars[level][line*perline + col][1] = y;
                
                PSET(x,  y,  color, LOGICAL_IMP );
            }
            
        }
    }
    
    //adicionais
    for (perline = 0; perline < 40; perline++) {
        PSET(rand()%SCREEN_W,  1+rand()%(PLAY_AREA_H-2),  DARK_BLUE, LOGICAL_IMP );
    }

}

void starsDraw() {
    int level;
    int i, x, y, color;
    stars_count[0]++;
    
    level = 0;
    while (level < STARS_PARALLAX_LEVELS && stars_count[level] == STARS_PARALLAX_FACT) {
        color = colors[level];
        stars_count[level] = 0;
        stars_count[level+1]++;
        for (i = 0; i < STARS_QTY_PER_LEVEL; i++) {
            x = stars[level][i][0];
            y = stars[level][i][1];
            PSET(x,  y,  BLACK, LOGICAL_IMP );
            stars[level][i][0] = (x+STARS_STEP)%SCREEN_W;
            PSET(stars[level][i][0],  y,  color, LOGICAL_IMP );
        }
        level++;
    }
    
}
