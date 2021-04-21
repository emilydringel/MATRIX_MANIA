def void testfloat(float a, float b){
    printf(a + b);
    printf(a - b);
    printf(a * b);
    printf(a / b);
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

    float c = 93.6;
    float d = 7.26;

    testfloat(c, d);

    testfloat(d, d);

}
