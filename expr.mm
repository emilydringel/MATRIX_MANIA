int length(matrix<> m) {return (m[0,0]* m[0,1]);}
int end(sequence m) {return length(m)-1;}
int size(matrix<> m) {return length(m);}
int rows(matrix<> m) { return (m[0,0]);}
int columns(matrix<> m) {return (m[0,1]);}

(* functions *)

(* DETERMINANT *)

float det(matrix<> a) { 
  matrix<> det; 
  int i; 
  int j; 
  int j1; 
  int j2; 
  matrix m; 
  float tmp; 
  if (rows(a) == 1) det = a[0, 0]; 
  else if (rows(a) == 2) det = a[0, 0] * a[1, 1] - a[0, 1] * a[1, 0]; 
  else { 
    det = [0.0;]; 
    for (j1 = 0; j1 < columns(a); j1 = j1 + 1) { 
      m = new matrix(rows(a) - 1, columns(a) - 1); 
      for (i = 1; i < rows(a); i = i + 1) { 
        j2 = 0; 
        for (j = 0; j < columns(a); j = j + 1) { 
           if (j != j1) { 
             m[i-1, j2] = a[i, j]; 
             j2 = j2 + 1; 
           } 
        } 
      } 
      det = det + [(-1.0 ^ ((j1) + 2.0));] * a[0, j1] * [det(m);]; 
    } 
  } 
  matrix<float> b = [det];
  return b;
} 


