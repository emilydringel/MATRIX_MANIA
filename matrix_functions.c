/*
 *  matrix_functions.c
 */

#include <stdio.h>
#include <string.h>

void printm(int* element_one) /* prints the matrix<int> */
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

/*
EXTRA FUNCTIONS FOR EXTRA TIME:
1. Matrix Multiplication (in semant)
2. Scalar Multiplication (in semant)
3. Add/Subtract two matrices (not in semant)
*/
