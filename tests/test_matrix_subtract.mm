def matrix<int> add(matrix<int> x, matrix<int> y){

    matrix<int> empty = [0,0];

    for(int i = 0; i < 2; i+1)
  	for(int j = 0; j < 2; j+1){
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
    printm(sub([6,8],[9,10]));
}
