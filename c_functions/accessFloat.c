/*
 *  accessFloat.c -- for accessing value in a matrix
 */

#include <stdio.h>
#include <string.h>

float accessFloat(float element_one[], int row, int col)
{
    int rows = (int) element_one[0];
    int cols = (int) element_one[1];
    int location = 2 + (row*cols) + col;
    return element_one[location];
}

int main()
{
}

