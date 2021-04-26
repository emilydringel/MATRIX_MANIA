/* Semant Check -- float = int */
def int main(){
<<<<<<< Updated upstream
    float x = 2.45;
    int y = x; /* Should throw an error */
    print(y);
=======
    int x = 0;
    float y = x; /* Should throw an error */
    float z = y + 1;
    y = 1; /* Should throw an error */
    printf(y);
>>>>>>> Stashed changes
}
