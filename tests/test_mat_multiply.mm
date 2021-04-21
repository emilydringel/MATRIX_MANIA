def matrix<int> multiply(matrix<int> x, matrix<int> y){
/* matrix<int> empty as parameter? */

    int sizeOfR1 = getRows(x);
    int sizeOfC1 = getColumns(x);
    int sizeOfR2 = getRows(y);
    int sizeOfC2= getColumns(y);

    matrix<int> empty = [0,0];

    for(int i = 0; i < sizeOfR1; i+1){
	for(int j = 0; j < sizeOfC2; j+1){
	    for(int k = 0; k < sizeOfC1; k+1){
		empty[i,j]+= x[i,k]*y[k,j];
	    }
  	}
    }
  return empty;
}

def int main(){
  
matrix<int> m = [1,4];
matrix<int> n = [2,3];

matrix<int> multiplied = multiply(m,n);

  printm(m);
  printm(n);
  printm(multiplied);
  printm(multiply([6,8],[9,10]));
}
