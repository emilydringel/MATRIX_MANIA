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

void printmf(double* element_one) /* prints the matrix<int> */
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
    if(m1[0]!=m2[0] || m1[1]!=m2[1]){
        printf("RUNTIME ERROR: matrices being added do not have the same dimensions.\n");
        exit(1);
    }
    int rows = m1[0];
    int cols = m1[1];
    int size = 2 + rows * cols;
    int *empty = malloc(size * sizeof(int));
    empty[0] = rows;
    empty[1] = cols;
    for (int i = 2; i < size; i++) {
        empty[i] = m1[i] + m2[i];
    }
    return empty;
}

double* addmf(double* m1, double* m2) 
{
    if(m1[0]!=m2[0] || m1[1]!=m2[1]){
        printf("RUNTIME ERROR: matrices being added do not have the same dimensions.\n");
        exit(1);
    }
    int rows = (int) m1[0];
    int cols = (int) m1[1];
    int size = 2 + rows * cols;
    double *empty = malloc(size * sizeof(double));
    empty[0] = rows;
    empty[1] = cols;
    for (int i = 2; i < size; i++) {
        empty[i] = m1[i] + m2[i];
    }
    return empty;
}

int* subm(int* m1, int* m2) 
{
    if(m1[0]!=m2[0] || m1[1]!=m2[1]){
        printf("RUNTIME ERROR: matrices being subtracted do not have the same dimensions.\n");
        exit(1);
    }
    int rows = m1[0];
    int cols = m1[1];
    int size = 2 + rows * cols;
    int *empty = malloc(size * sizeof(int));
    empty[0] = rows;
    empty[1] = cols;
    for (int i = 2; i < size; i++) {
        empty[i] = m1[i] - m2[i];
    }
    return empty;
}

double* submf(double* m1, double* m2) 
{
    if(m1[0]!=m2[0] || m1[1]!=m2[1]){
        printf("RUNTIME ERROR: matrices being subtracted do not have the same dimensions.\n");
        exit(1);
    }
    int rows = (int) m1[0];
    int cols = (int) m1[1];
    int size = 2 + rows * cols;
    double *empty = malloc(size * sizeof(double));
    empty[0] = rows;
    empty[1] = cols;
    for (int i = 2; i < size; i++) {
        empty[i] = m1[i] - m2[i];
    }
    return empty;
}

int* scalarm(double x, int* m){
    int rows = m[0];
    int cols = m[1];
    int size = 2 + rows * cols;
    int *empty = malloc(size * sizeof(int));
    for (int i = 0; i < size; i++) {
        empty[i] = m[i];
        if(i>=2){
            empty[i] *= (int) x;
        }
    }
    return empty;
}

double* scalarmf(double x, double* m){
    int rows = (int) m[0];
    int cols = (int) m[1];
    int size = 2 + rows * cols;
    double *empty = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        empty[i] = m[i];
        if(i>=2){
            empty[i] *= x;
        }
    }
    return empty;
}

int* multiplication(int* m1, int* m2){
    if(m1[1]!=m2[0]){
        printf("RUNTIME ERROR: matrices being multiplied do not have complementary dimensions.\n");
        exit(1);
    }
    int rows_one = m1[0];
    int rows_two = m2[0];
    int cols_one = m1[1];
    int cols_two = m2[1];
    int *empty = malloc(rows_one * cols_two * sizeof(int));
    empty[0] = rows_one;
    empty[1] = cols_two;
    for(int row=0; row<rows_one; row++){
        for(int col=0; col<cols_two; col++){
            empty[2+(cols_two*row)+col] = 0;
            for(int val=0; val<cols_one; val++){
                int x = m1[2+cols_one*row+val]*m2[2+cols_two*val+col];
                empty[2+cols_two*row+col] += x;
            }
        }
    }
    return empty;
}

double* multiplicationf(double* m1, double* m2){
    if(m1[1]!=m2[0]){
        printf("RUNTIME ERROR: matrices being multiplied do not have complementary dimensions.\n");
        exit(1);
    }
    int rows_one = (int) m1[0];
    int rows_two = (int) m2[0];
    int cols_one = (int) m1[1];
    int cols_two = (int) m2[1];
    double *empty = malloc(rows_one * cols_two * sizeof(int));
    empty[0] = (double) rows_one;
    empty[1] = (double) cols_two;
    for(int row=0; row<rows_one; row++){
        for(int col=0; col<cols_two; col++){
            empty[2+(cols_two*row)+col] = 0;
            for(int val=0; val<cols_one; val++){
                double x = m1[2+cols_one*row+val]*m2[2+cols_two*val+col];
                empty[2+cols_two*row+col] += x;
            }
        }
    }
    return empty;
}

int equal(int *m1, int *m2){
    int rows_one = m1[0];
    int rows_two = m2[0];
    int cols_one = m1[1];
    int cols_two = m2[1];
    if(rows_one!=rows_two || cols_one!=cols_two){
        return 0;
    }
    int size = 2 + rows_one*cols_one;
    for(int i=0; i<size; i++){
        if(m1[i]!=m2[i]){
            return 0;
        }
    }
    return 1;
}

int equalf(double *m1, double *m2){
    int rows_one = (int) m1[0];
    int rows_two = (int) m2[0];
    int cols_one = (int) m1[1];
    int cols_two = (int) m2[1];
    if(rows_one!=rows_two || cols_one!=cols_two){
        return 0;
    }
    int size = 2 + rows_one*cols_one;
    for(int i=0; i<size; i++){
        if(m1[i]!=m2[i]){
            return 0;
        }
    }
    return 1;
}
/*
int main(){
    int m1[] = {3,4,7,3,4,5,0,8,3,1,1,4,2,5};
    int m2[] = {4,2,3,6,9,1,2,4,6,8};
    int empty[] = {0,0,0,0,0,0,0,0};
    multiplication(m1, m2, empty);
    printm(empty);
}
*/
