(* built-in functions *)

(* size *)

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static void die(const char *m){
 perror(m);
 exit(1);
}

struct matrix{
 int n_rows;
 int n_columns;
}
typedef struct matrix matrix;

matrix* size(matrix* mat){
 int size[] = {mat->n_rows, mat->n_columns};
 return size; 
 
 
}


