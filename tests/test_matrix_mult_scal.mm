def void multiply_s(matrix<int> x, int y){
    
    int sizeOfR1 = getRows(x);
    int sizeOfC1= getColumns(x);

    for(int i = 0; i < sizeOfR1; i=i+1){
        for(int j = 0; j < sizeOfC1; j=j+1){
            x[i,j] = x[i,j] * y;
  	}
    }
}


def int main(){
  
    matrix<int> m = [1,2,3;4,5,6];
    int n = 2;  

    multiply_s(m, n);
    printm(m);
}
