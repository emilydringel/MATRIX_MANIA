def int main( ){

Matrix<Int> m = [1,2,3; 4,5,6];
Matrix<Int> n = [0,0,0; 0,0,0];
Matrix<Int> tranposed = transpose(m);

def Matrix<Int> transpose(Matrix<Int> m, Matrix<Int> n){
 Matrix<Int> rowscols = size(m);

 for(int i = 0; i < rowscols[0,0]; i++){
  for(int j = 0; j < rowscols[1,0]; j++)
	n[i,j] = m[j,i];  
}
 return n;
}
 print(transpose([1,2,3; 4,5,6],[0,0,0;0,0,0]);
 print(transpose([7,8,9; 10,11,12], [0,0,0; 0,0,0]);
 return 0;
} 
