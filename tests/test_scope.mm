/* Semant Check -- scoping */
def float add(float x){
    float y = 5.0; 
    float z = 0.0;  
    while(y>0){
        z = x + y; 
        y = y-1.0;
    }
    return z; 
}
def int main(){
    printf(add(6.0));
}

