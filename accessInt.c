/*
 *  accessInt.c -- for accessing value in a matrix
 */

#include <stdio.h>
#include <string.h>

int accessInt(int element_one[], int row, int col)
{
    int rows = element_one[0];
    int cols = element_one[1];
    int location = 2 + (row*cols) + col;
    return element_one[location];
}

int main()
{
}


