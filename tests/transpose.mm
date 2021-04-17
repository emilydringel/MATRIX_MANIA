def int main( ){

matrix<int> m = [1,2,3; 4,5,6];
matrix<int> n = [0,0;0,0;0,0];
matrix<int> tranposed = transpose(m,m);

def matrix<int> transpose(matrix<int> m, matrix<int> n){
 matrix<int> rowscols = size(m);

 for(int i = 0; i < rowscols[0,0]; i++){
  for(int j = 0; j < rowscols[1,0]; j++)
	n[i,j] = m[j,i];  
}
 return n;
}
 print(m);
 print(transposed);

 print(transpose([7,8,9,10; 11,12,13,14]);
 print(transpose([7,8,9,10; 11,12,13,14],[0,0;0,0;0,0;0,0]);
 return 0;
} 
