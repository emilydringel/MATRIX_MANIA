def void transpose(matrix<int> original, matrix<int> result){
    /* using built-in functions getRows and getColumns */
    int rows = getRows(original);
    int cols = getColumns(original);

    for(int i = 0; i < cols; i=i+1){
	    for(int j = 0; j < rows; j=j+1){
            result[i, j] = original[j, i];
	    }
    }
}

def int main(){
    /* declare matrix */
    matrix<int> A = [1, 2, 3;
                     4, 5, 6];
    printm(A);

    print(1111111111);

    /* declare result matrix */
    matrix<int> A_T = [0, 0; 
                       0, 0;
                       0, 0];
    transpose(A, A_T);

    printm(A_T);

    return 0;
}
