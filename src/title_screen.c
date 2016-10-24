#include "title_screen.h"


#include <VDPgraph2.h>
#include <types.h>
#include <stdlib.h>
#include "graph_aux.h"
#include "defines.h"
#include "joystick.h"

#include "psg.h"

int showTitleScreen() {
 int players;
 int option = 0;
 unsigned char keyRelease = 1;
 unsigned int seed = 0;
 unsigned char k1, j1, j2;
 
 ResetSprites();
 SetBorderColor(BLACK);
 SetColors( WHITE, BLACK, BLACK );
 ClearScreen();
 
 //Tela de título
 SetColors( MEDIUM_RED, BLACK, BLACK );
 PutText(22,50, "       PONG BLASTER       ");
 
 SetColors( WHITE, BLACK, BLACK );
 PutText(22,100,"         1 Player         ");
 PutText(22,120,"         2 Players        ");
 PutText(22,150,"           Quit           ");
 
 SetColors( DARK_BLUE, BLACK, BLACK );
 PutText(22,202,"  2016 - Felipe K F Costa ");
 
 SetColors( WHITE, BLACK, BLACK );
 do {
    k1 = keyboard_read();
    j1 = joystick_1_read();
    j2 = joystick_2_read();
    seed++;
    
    if ( (k1 & KB_UP) || (j1 & JOY_UP) ) {
        if (keyRelease == 1) {
            option--;
            if (option == -1) option = 2;
            keyRelease = 0;
        }
    } else if ( (k1 & KB_DOWN) || (j1 & JOY_DOWN) ) {
        if (keyRelease == 1) {
            option++;
            if (option == 3) option = 0;
            keyRelease = 0;
        }
    } else {
        keyRelease = 1;
    }
    
    if (option == 0) { // 1 player
        PutText(22,100,"   -");
        PutText(22,120,"    ");
        PutText(22,150,"    ");
    } else if (option == 1) { // 2 players 
        PutText(22,100,"    ");
        PutText(22,120,"   -");
        PutText(22,150,"    ");
    } else if (option == 2) { // quit
        PutText(22,100,"    ");
        PutText(22,120,"    ");
        PutText(22,150,"   -");
    } 

 } while ( !(k1 & KB_SPACE) && !(j1 & JOY_TRIG_A) && !(j2 & JOY_TRIG_A) );
 
 
 srand(seed);
 
 ClearScreen();
 
 players = (option + 1) % 3;
 
 return players;
}
