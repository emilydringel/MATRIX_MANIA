/* Semant Check -- scoping */

def float add(float x){
    float y = 5.0;
    while(y>0){
        float z = x + y; 
        y = y-1.0;
    }
    return z; 
}

def int main(){
    int x = 0;
    int y = x;
    printf(add(6.0));
}

