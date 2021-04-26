def void multiply(matrix<int> x, matrix<int> y, matrix<int> empty){

  int x_rows = getRows(x);
  int y_cols = getColumns(y);
  int y_rows = getRows(y);

  for(int i = 0; i < x_rows; i=i+1){
    for(int j = 0; j < y_cols; j=j+1){
      for(int k = 0; k < y_rows; k =k+1) {
        empty[i,j] = empty[i,j] + x[i,k] * y[k,j];
      }
    }
  }
}

def int main(){

  matrix<int> m = [1, 0, 0;
                   0, 1, 0;
                   0, 0, 1];
  matrix<int> n = [1, 2, 3;
                   5, 6, 7;
                   8, 9, 10];
  matrix<int> empty3 = [0, 0, 0;
                        0, 0, 0;
                        0, 0, 0];
  multiply(m, n, empty3);
  printm(empty3);
  
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
