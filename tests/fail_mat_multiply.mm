def int main( ){

matrix<int> m = [1,4];
matrix<int> n = [2,3];

matrix<int> multiplied = multiply(m,n);

  printm(m);
  printm(n);
  printm(multiplied);
  printm(multiply([6,8; 9,10,11])); /* Fail: invalid matrix dims */
  return 0;
}

