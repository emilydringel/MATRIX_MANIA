/*
 *  sizeFloat.c -- for accessing size of matrix
 */

#include <stdio.h>
#include <string.h>

int* sizeFloat(float element_one[])
{
    int rows = (int) element_one[0];
    int cols = (int) element_one[1];
    int* ret = malloc(2*sizeof(int));
    ret[0] = rows;
    ret[1] = cols;
    return ret;
}

int main()
{
  float s[] = {2,3,1,2,3,4,5,6};
  printf(sizeFloat(s));
}

