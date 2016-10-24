#include "sqrt.h"

#define SQRT_ERROR 0.01 /* e decides the accuracy level*/

float sqrt(float n)
{
  /*We are using n itself as initial approximation
   This can definitely be improved */
  float x = n;
  float y = 1;
  while(x - y > SQRT_ERROR)
  {
    x = (x + y)/2;
    y = n/x;
  }
  return x;
}