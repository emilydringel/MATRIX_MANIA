def int main(){
    /*matrix<int> m1 = [1,2,3;4,5,6];
    matrix<int> m2 = [6,5,4;3,2,1];
    printm(m1+m2);
    printm(m1-m2);
    printm(m1*3);
    printm(3*m1);
    printm(m1*3.5);
    printm(3.5*m1);
    matrix<int> m3 = [1,2;3,4;5,6];
    printm(m1*m3);
    int x = (m1!=m3);
    print(m1==m3);
    print(x);*/
    matrix<float> m1 = [.1,.2,.3;.4,.5,.6];
    matrix<float> m2 = [.6,.5,.4;.3,.2,.1];
    printmf(m1+m2);
    printmf(m1-m2);
    printmf(m1*3);
    printmf(3*m1);
    printmf(m1*3.5);
    printmf(3.5*m1);
    matrix<float> m3 = [1.1,2.2;3.3,4.4;5.5,6.6];
    printmf(m1*m3);
    print(m1==m3);
    print(m1!=m3);
}