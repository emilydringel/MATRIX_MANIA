def int det(matrix<int> x){
    return (x[0,0] * x[1,1] - x[0,1] * x[1,0]);
}
def int main( ){
	matrix<int> m = [1,2;3,4];	
	int d = det(m);
	print(d);	
}
