def matrix<int> transpose(matrix<int> original, matrix<int> result){
    int sizeOfR1 = getRows(original);
    int sizeOfC1= getColumns(original);

    for(int i = 0; i < sizeOfR1; i=i+1){
        for(int j = 0; j < sizeOfC1; j=j+1){
            result[i,j] = original[j,i];
        }
}
    return result;
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

