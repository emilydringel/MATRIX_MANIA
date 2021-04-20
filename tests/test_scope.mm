/* Semant Check -- scoping */

def float add(float x){
    float y = 5.0;
    while(0){
        float z = x + y; 
    }
    return z; /* should give an error */
}

def int main(){
    int x = 0;
    int y = x;
    printf(add(6.0));
}

