/* operators on ints */ 

def void testint(int a, int b){
    print(a + b);
    print(a - b);
    print(a * b);
    print(a / b);
    print(a == b);
    print(a == a);
    print(a != b);
    print(a != a);
    print(a > b);
    print(a >= b);
    print(a < b);
    print(a <= b);
}
def int main(){

    int c = 80;
    int d = 5;

    testint(c, d);

    testint(d, d);
}
