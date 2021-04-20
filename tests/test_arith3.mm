def int foo(int a) (*should be ignored*)
{
  return a;
}

def int main()
{
  int a = 3;
  a = a + 5;
  print(a);
}