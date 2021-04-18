/*
 *  printm.c -- for printing int matrices
 */

#include <stdio.h>
#include <string.h>

void printm(int* element_one)
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

/*
int main()
{
  int s[] = {2,3,1,2,3,4,5,6};
  printm(s);
}
*/
