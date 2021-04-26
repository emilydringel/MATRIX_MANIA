/* Semant Check -- scoping */
def float add(float x){
    float y = 5.0;
    while(y>1.0){
        float z = x + y; 
    }
    return z; 
}

def int main(){
    int x = 0;
    int y = x;
    printf(add(6.0));
}

