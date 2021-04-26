def void transpose(matrix<int> original, matrix<int> result){
    int sizeOfR1 = getRows(original);
    int sizeOfC1= getColumns(original);

    for(int i = 0; i < sizeOfC1; i=i+1){
	    for(int j = 0; j < sizeOfR1; j=j+1){
            result[i,j] = original[j,i];
	    }
    }
}

def int main(){

    matrix<int> m = [1,2,3;4,5,6];
    printm(m);
    
    matrix<int> n = [0,0;0,0;0,0];
    transpose(m,n);
    printm(n); 


    matrix<int> m = [1,2,3,8,3,23,4,44; 11,9,31,2,13,33,0,17];
    printm(m);

    matrix<int> p = [0,0;0,0;0,0;0,0;0,0;0,0;0,0;0,0];
    transpose(m,p);
    printm(p); 


} 
