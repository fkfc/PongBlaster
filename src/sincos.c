#include "sincos.h"

float cos(float x){
	if( x < 0.0f ) 
		x = -x;
	while( M_PI < x )
		x -= M_2_PI;
	return 1.0f - (x*x/2.0f)*( 1.0f - (x*x/12.0f) * ( 1.0f - (x*x/30.0f) * (1.0f - x*x/56.0f )));
}
 
float sin(float x){return cos(x-M_PI_2);}
 