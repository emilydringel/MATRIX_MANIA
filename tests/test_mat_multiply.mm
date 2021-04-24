def matrix<int> multiply(matrix<int> x, matrix<int> y, matrix<int> empty){

  int sizeOfR1 = getRows(x);
  int sizeOfC1 = getColumns(x);
  
  int i = 0;
  int j = 0;

  for(; i < sizeOfR1; i=i+1){
    for(; j < sizeOfC1; j=j+1){
      empty[i,j]+= x[i,j]*y[i,j];
    }
  }
  /* return empty; */
  /*  matrix<int> result = matrix<int> empty; */
}

def int main(){

  matrix<int> empty3 = [0,0];
  multiply([1,1],[2,2],empty3);
  printm(empty);
  
  /*
  matrix<int> m = [1,4];
  matrix<int> n = [2,3];
  matrix<int> empty = [0,0];
  matrix<int> empty2 = [0,0];

  matrix<int> multiplied = multiply(m,n, empty);
  matrix<int> multiplied2 = multiply([6,8],[9,10], empty2);


  printm(m);
  printm(n);
  printm(multiplied);
  printm(multiplied2);
  */
}
