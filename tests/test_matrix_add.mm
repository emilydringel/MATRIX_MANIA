def matrix<int> add(matrix<int> x, matrix<int> y){

    matrix<int> empty = [0,0];

    for(int i = 0; i < 2; i++){
    	for(int j = 0; j < 2; j++){
            empty[i,j] = x[i,j]+y[i,j];
        }
  	return empty;
    }
}


def int main(){
  
    matrix<int> m = [1,4];
    matrix<int> n = [2,3];

    matrix<int> added = add(m,n);

    printm(m);
    printm(n);
    printm(added);
    printm(add([6,8],[9,10]));
}
