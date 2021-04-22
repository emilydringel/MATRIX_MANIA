/*
 *  sizeInt.c -- for getting size of matrix
 */

#include <stdio.h>
#include <string.h>
/* UPDATE TO GET ROWS AND GET COLS */
int* sizeInt(int element_one[])
{
    int rows = element_one[0];
    int cols = element_one[1];
    int* ret = malloc(2*sizeof(int));
    ret[0] = rows;
    ret[1] = cols; 
    return ret;
}

int main()
{
  int s[] = {2,3,1,2,3,4,5,6};
  printf(size(s));
}

