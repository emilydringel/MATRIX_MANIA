def matrix<int> add(matrix<int> x, matrix<int> y){

matrix<int> rowscols = size(x);
matrix<int> empty = [0,0];

for(int i = 0; i < rowscols[0,0]; i++)
  for(int j = 0; j < rowscols[1,0]; j++){
    empty[i,j] = x[i,j]-y[i,j];
  }
  return empty;
}


def int main( ){
  
matrix<int> m = [1,4];
matrix<int> n = [2,3];

matrix<int> subtract = sub(m,n);

  printm(m);
  printm(n);
  printm(subtract);
  printm(sub([6,8; 9,10]));
}
