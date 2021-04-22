def matrix<int> multiply_s(matrix<int> x, matrix<int> empty, int y){
    
    int sizeOfR1 = getRows(x);
    int sizeOfC1= getColumns(x);

    for(int i = 0; i < sizeOfR1; i+1)
	for(int j = 0; j < sizeOfC1; j+1){
            empty[i,j] = x[i,j] * y;
    	}
        return empty;
}


def int main( ){
  
    matrix<int> m = [1,4,3;2,7,6];
    matrix<int> empty = [0,0,0;0,0,0];
    int n = 2;  

    matrix<int> multiplied = multiply_s(m,n);

    printm(multiplied);
    printm(multiply_s([6,8,9;9,10,11],)); /*Fail: missing argument */
}
