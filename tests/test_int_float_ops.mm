/* operators on ints and floats */ 

def void testintflot(int a, float b){
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
    int c;
    float d;

    c = 80;
    d = 5.5;

    testintfloat(c, d);

    testintfloat(d, d);
}