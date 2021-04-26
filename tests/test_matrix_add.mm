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