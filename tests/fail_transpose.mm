def matrix<int> transpose(matrix<int> m, matrix<int> n){
 matrix<int> rowscols = size(m);

 for(int i = 0; i < rowscols[0,0]; i=i+1){
  for(int j = 0; j < rowscols[1,0]; j=j+1)
	n[i,j] = m[j,i];  
}
 return n;
}

def int main(){

matrix<float> m = [1,2,3; 4,5,6]; /* Fail: incompatible types */
matrix<int> n = [0,0;0,0;0,0];
matrix<int> tranposed = transpose(m,m);


 printm(m);
 printm(transposed);

 printm(transpose([7,8,9,10; 11,12,13,14]);
 printm(transpose([7,8,9,10; 11,12,13,14],[0,0;0,0;0,0;0,0]);
} 
