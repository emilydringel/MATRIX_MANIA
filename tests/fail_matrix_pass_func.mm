def void pass(matrix<int> a){
        matrix<int> temp = a;
        printm(temp);
}
def int main(){
        matrix<int> a = [1,2];
        pass(b); /* Fail: undeclared identifier b */ 
}
