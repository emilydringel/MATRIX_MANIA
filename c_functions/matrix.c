/*  built-in functions */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static void die(const char *m){
 perror(m);
 exit(1);
}

struct matrix{
 int num_rows;
 int num_cols;
 int** matrixAddr;
 int buildPosition;
};
typedef struct matrix matrix;
int debug = 0;

int* size(matrix* mat)
{
/*
size of int * int
put array into struct
allocate inside struct
*/
 int *sizem[] = {mat->num_rows, mat->num_cols};
 return &sizem;  
}

matrix* initMatrix(int* listOfValues, int num_cols, int num_rows) {
  int** matrixValues = malloc(num_rows * sizeof(int*));

  if(debug == 1) {
      printf("Building matrix:\n");
      printf("num_rows: %d\n", num_rows);
      printf("num_cols: %d\n", num_cols);
  }

  //set all values in matrix to NULL if list of values is NULL
  if (listOfValues == NULL) {
    for(int i = 0; i < num_rows; i++) {
      int* matrix_row = malloc(num_cols * sizeof(int));
      *(matrixValues + i) = matrix_row;
      for(int j = 0; j < num_cols; j++) {
        matrix_row[j] = 0;
      }
    }
  }

  //load values from a list of values
  else {
    for(int i = 0; i < num_cols; i++) {
      int* matrix_col = malloc(num_rows * sizeof(int));
      *(matrixValues + i) = matrix_col;
      for(int j = 0; j < num_rows; j++) {
        matrix_col[j] = listOfValues[i*num_rows + j];
      }
    }
  }

  //return a pointer to matrix struct
  matrix* result = malloc(sizeof(struct matrix));
  result->num_cols = num_cols;
  result->num_rows = num_rows;
  result->matrixAddr = matrixValues;
  result->buildPosition = 0;
  return result;
}
/* display function */
void display(int* r ){
 printf("Row %d", r[0]);
 printf("Col %d", r[1]);
}

void display1(matrix* input) {
    int row = input->num_rows;
    int col = input->num_cols;
    for(int i = 0; i<row; i++) {
        for(int j=0; j<col; j++) {
            printf(" %d", input->matrixAddr[i][j]);
        }
        printf("\n");
    }
}


#ifdef BUILD_TEST


int main(){


/* size */
 int val[] = {1,2,3,4};
 int *list1 = val;
 matrix *m = initMatrix(list1, 2, 2);
/* printf("The size is %d\n", size({1,2,3,4}); */
 display(size(m));
 return 0;
}
#endif

