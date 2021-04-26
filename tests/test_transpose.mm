def void transpose(matrix<int> original, matrix<int> result){
    int sizeOfR1 = getRows(original);
    int sizeOfC1= getColumns(original);

    for(int i = 0; i < sizeOfR1; i=i+1){
	    for(int j = 0; j < sizeOfC1; j=j+1){
            result[i,j] = original[j,i];
	    }
    }
}

def int main(){

    matrix<int> m = [1,2,3; 4,5,6];
    matrix<int> n = [0,0;0,0;0,0];
    matrix<int> tranposed = transpose(m,n);


    printm(m);
    printm(transposed);

    /*printm(transpose([7,8,9,10; 11,12,13,14]);*/
    printm(transpose([7,8,9,10; 11,12,13,14],[0,0;0,0;0,0;0,0]);
} 
