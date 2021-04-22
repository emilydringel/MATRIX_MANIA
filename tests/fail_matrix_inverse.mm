def int inverse(){
def matrix<int> multiply_s(matrix<int> x, int y){

    int sizeOfR1 = getRows(x);
    int sizeOfC1 = getColumns(x);
    matrix<int> empty = [0,0;0,0];

    for(int i = 0; i < rowscols[0,0]; i=i+1)
  	for(int j = 0; j < rowscols[1,0]; j=j+1){
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
        
        matrix<int> a = [4,3;3,2,1]; /* Fail: invalid matrix dims */
        matrix<int> inversed = inverse(a);
        printm(inversed); 
}
