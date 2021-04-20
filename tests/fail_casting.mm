/* Semant Check -- float = int */
def int main(){
    int x = 0;
    float y = x; /* Should throw an error */
    printf(y);
}
