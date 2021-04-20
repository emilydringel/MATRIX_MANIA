<<<<<<< HEAD
def int inverse(){
=======
def matrix<int> multiply_s(matrix<int> x, int y){

matrix<int> rowscols = size(x);
matrix<int> empty = [0,0;0,0];

for(int i = 0; i < rowscols[0,0]; i+1)
  for(int j = 0; j < rowscols[1,0]; j+1){
    empty[i,j] = x[i,j] * y;
  }
  return empty;
}

def int det(matrix<int> x){   
  return ((x[0,0] * x[1,1]) - (x[0,1] * x[1,0]));
}

def int inverse(matrix<int> x){

   int det_var = det(x);

   if (det_var == 0){
      return [-1];
   }

    second_val = multiply_s(x[0,1], -1);
    third_val = multiply_s(x[1,0], -1);

    return multiply_s([x[1,1], second_val, third_val, x[0,0]], (1/det));
}

def int main(){
        
        matrix<int> a = [1,2;3,4];
        matrix<int> inversed = inverse(a);
        printm(d); 
>>>>>>> 0b9c1de60f972470fa68078ae633a80904453f20
}
