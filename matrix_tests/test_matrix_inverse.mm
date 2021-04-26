def void multiply_s(matrix<int> x, float y){
    
    int sizeOfR1 = getRows(x);
    int sizeOfC1= getColumns(x);

    for(int i = 0; i < sizeOfR1; i=i+1){
        for(int j = 0; j < sizeOfC1; j=j+1){
            x[i,j] = x[i,j] * y;
  	}
    }
}

def int det(matrix<int> x){   
    return ((x[0,0] * x[1,1]) - (x[0,1] * x[1,0]));
}

def int inverse(matrix<int> x){

    int det_var = det(x);

    if (det_var == 0){
      return 1;
   }

    int second_val = multiply_s(x[0,1], -1);
    int third_val = multiply_s(x[1,0], -1);
    multiply_s([x[1,1], second_val, third_val, x[0,0]], (1/det));
    return 0;
}

def int main(){
        
    matrix<int> a = [4,3;3,2];
    inverse(a);
    printm(a); 
}
