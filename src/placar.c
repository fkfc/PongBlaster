#include "placar.h"
#include <stdio.h>
#include <VDPgraph2.h>
#include <types.h>
#include "psg.h"
#include "sound_manager.h"
#include "defines.h"
#include "graph_aux.h"

int placar_placar[2]  ;

//TA - TADA!
const unsigned int  GOAL_SOUND[] = { PSG_A4, 0 , PSG_F4 , PSG_C5, PSG_C5 , PSG_C5};
const unsigned char GOAL_SOUND_SIZE = 6;


int *getPlacar(int p) {
    static int placar[2];
    return &(placar[p]);
}


void drawPlacarTile(int x1, int y1) {
    // http://bgmaker.ventdaval.com/
    
    PSET( x1+0, y1+0,  WHITE, LOGICAL_IMP );
    PSET( x1+1, y1+1,  WHITE, LOGICAL_IMP );
    PSET( x1+1, y1+2,  WHITE, LOGICAL_IMP );
    PSET( x1+0, y1+3,  WHITE, LOGICAL_IMP );
    
    LINE( x1+4, y1+0, x1+4, y1+1, WHITE, LOGICAL_IMP );
    LINE( x1+5, y1+1, x1+7, y1+1, WHITE, LOGICAL_IMP );
    
    
    PSET( x1+11, y1+0,  WHITE, LOGICAL_IMP );
    PSET( x1+10, y1+1,  WHITE, LOGICAL_IMP );
    PSET( x1+10, y1+2,  WHITE, LOGICAL_IMP );
    PSET( x1+11, y1+3,  WHITE, LOGICAL_IMP );
    
    PSET( x1+3, y1+3,  WHITE, LOGICAL_IMP );
    PSET( x1+4, y1+4,  WHITE, LOGICAL_IMP );
    LINE( x1+5, y1+5, x1+10, y1+5, WHITE, LOGICAL_IMP );
    PSET( x1+11, y1+6,  WHITE, LOGICAL_IMP );
    
    
    LINE( x1+0, y1+3, x1+4, y1+7, WHITE, LOGICAL_IMP );
    LINE( x1+5, y1+8, x1+9, y1+8, WHITE, LOGICAL_IMP );
    PSET( x1+8, y1+9,  WHITE, LOGICAL_IMP );
    PSET( x1+9, y1+9,  WHITE, LOGICAL_IMP );
    
    PSET( x1+0, y1+7,  WHITE, LOGICAL_IMP );
    PSET( x1+1, y1+8,  WHITE, LOGICAL_IMP );
    PSET( x1+2, y1+8,  WHITE, LOGICAL_IMP );
    PSET( x1+3, y1+9,  WHITE, LOGICAL_IMP );
    //PSET( x1+4, y1+10,  WHITE, LOGICAL_IMP );
    //PSET( x1+4, y1+11,  WHITE, LOGICAL_IMP );
    

}


void setupPlacar() {
    int *p1, *p2;
    unsigned char i;
    p1 = getPlacar(0);
    p2 = getPlacar(1);
    
    *p1 = 0;
    *p2 = 0;
    
    //desenha a base
    SetColors( BLACK, GRAY, GRAY );
    RECT( 0, PLAY_AREA_H, SCREEN_W-1, SCREEN_H-1, GRAY, FILL_ALL );
    
    for (i = 0; i < 21; i++) {
        drawPlacarTile(12*i+2, PLAY_AREA_H);
    }
}


void incPlacar(int player) {
    int *p;
    if (player == 1) {
        p =  getPlacar(0);
        *p = (*p) + 1;
    }
    if (player == 2) {
        p =  getPlacar(1);
        *p = (*p) + 1;
    }
    
}


void drawPlacar() {
   int *p1, *p2;
   char string[10];

   p1 = getPlacar(0);
   p2 = getPlacar(1);
   
   SetColors( BLACK, GRAY, GRAY );

   sprintf(string, "%d\0", *p1);
   PutText(10,202,string);
   
   sprintf(string, "%d\0", *p2);
   PutText(235,202,string);

}


void goalPlacar(int player) {
    unsigned int delay;
    unsigned char count;
    int *p;
    char string[10];
    
    incPlacar(player);
    drawPlacar();
    
    SetColors( DARK_GREEN, GRAY, GRAY );
    
    if (player == 1) {
        p = getPlacar(0);
        sprintf(string, "%d\0", *p);
        PutText(10,202,string);
    } else {
        p = getPlacar(1);
        sprintf(string, "%d\0", *p);
        PutText(235,202,string);
    }
    
    SoundManager.play(SOUND_MANAGER_CHANNEL_A, GOAL_SOUND, GOAL_SOUND_SIZE);
    for (count = 0; count < (GOAL_SOUND_SIZE + 1); count++) {
        soundManagerIterate();
        for (delay = 0; delay < 10000; delay++);
    }
    
    SetColors( BLACK, GRAY, GRAY );
    if (player == 1) {
        PutText(10,202,string);
    } else {
        PutText(235,202,string);
    }
}



const struct t_placar Placar = {
     .goal = goalPlacar,
     .inc = incPlacar,
     .draw = drawPlacar,
     .setup = setupPlacar
};

