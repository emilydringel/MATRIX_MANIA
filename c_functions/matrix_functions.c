/*
 *  matrix_functions.c
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int printm(int* element_one) /* prints the matrix<int> */
{
    int rows = element_one[0];
    int cols = element_one[1];
    int size = rows * cols;
    char matrix[size*100]; /* maybe should be better about size?? */
    strcpy(matrix, "");
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            int location = 2 + (i*cols) + j;
            char buffer[1000];
            sprintf(buffer, "%d", element_one[location]);
            strcat(matrix, buffer);
            if(j!=cols-1){
                strcat(matrix, " ");
            }
        }
        if(i!=rows-1){
            strcat(matrix, "\n");
        }
    }
    printf("%s\n", matrix);
    return 0;
}

void printmf(float* element_one) /* prints the matrix<int> */
{
    int rows = (int) element_one[0];
    int cols = (int) element_one[1];
    int size = rows * cols;
    char matrix[size*100]; /* maybe should be better about size?? */
    strcpy(matrix, "");
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < cols; j++){
            int location = 2 + (i*cols) + j;
            char buffer[1000];
            sprintf(buffer, "%f", element_one[location]);
            strcat(matrix, buffer);
            if(j!=cols-1){
                strcat(matrix, " ");
            }
        }
        if(i!=rows-1){
            strcat(matrix, "\n");
        }
    }
    printf("%s\n", matrix);
}

int* addm(int* m1, int* m2) 
{
    int rows = (int) m1[0];
    int cols = (int) m1[1];
    int size = 2 + rows * cols;
    int* m = malloc(sizeof(int) * size);
    m[0] = rows;
    m[1] = cols;
    for (int i = 2; i < size; i++) {
        m[i] = m1[i] + m2[i];
    }
    return m;
}

/*
EXTRA FUNCTIONS FOR EXTRA TIME:
1. Matrix Multiplication (in semant)
2. Scalar Multiplication (in semant)
3. Add/Subtract two matrices (not in semant)
*/
