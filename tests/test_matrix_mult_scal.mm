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
    matrix<int> n = [1,2,3;4,5,6];
    int k = 2;  

    printm(k * m);
    multiply_s(m, k);
    printm(m);
}
