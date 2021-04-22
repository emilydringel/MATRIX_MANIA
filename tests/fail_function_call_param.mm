def int test(z) { /* Fail: variable declaration expected */
    return z;
}

def int main(){
    int y = 4;
    int x = test(y);
    print(x);
}
