def int gcd(int x, int y){
   if (x == 0){
      return y;
   }
   while(x != y){
      if(x > y) {x = x - y;}
      else {y = y - x;}
   }
   return x;
}
def int main( ){
   print(gcd(3, 15));
   print(gcd(18,24));
   print(gcd(45)); /* Fail: expecting 2 arguments */
}
~      
