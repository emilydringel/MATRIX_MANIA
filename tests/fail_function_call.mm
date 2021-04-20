/* failing function call */ 
def int test() {
    return 20;
}
def int main( ){
    int x = send(); /* no function send */ 
    print(x);
}