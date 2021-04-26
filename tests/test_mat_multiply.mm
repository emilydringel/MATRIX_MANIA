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
                   0, 2, 0;
                   0, 0, 3];
  matrix<int> n = [1, 2, 3;
                   5, 6, 7;
                   8, 9, 10];
  matrix<int> empty3 = [0, 0, 0;
                        0, 0, 0;
                        0, 0, 0];
  multiply(m, n, empty3);
  printm(empty3);
  printm(m*n);
}
