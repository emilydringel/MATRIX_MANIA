def int main(){
  
    matrix<int> m = [1,4];
    matrix<int> n = [2,3];
    matrix<int> empty = [0,0];

    int sizeOfR1 = getRows(m);
    int sizeOfC1 = getColumns(m);

    for(int i = 0; i < sizeOfR1; i=i+1){
    	for(int j = 0; j < sizeOfC1; j=j+1){
            empty[i,j] = m[i,j] + n[i,j];
        }
    }

    printm(empty);

}


/*def matrix<int> add(matrix<int> x, matrix<int> y, matrix<int> empty){

    int sizeOfR1 = getRows(x);
    int sizeOfC1 = getColumns(x);

    int i = 0;
    for(i = 0; i < sizeOfR1; i=i+1){
        int j = 0;
    	for(j = 0; j < sizeOfC1; j=j+1){
            empty[i,j] = x[i,j]+y[i,j];
        }
  	return empty;
    }
}


def int main(){
  
    matrix<int> m = [1,4];
    matrix<int> n = [2,3];
    matrix<int> empty = [0,0];

    matrix<int> added = add(m,n);

    printm(m);
    printm(n);
    printm(added);
    printm(add([6,8],[9,10]));
}
/*
