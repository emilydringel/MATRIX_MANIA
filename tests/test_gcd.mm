/*gcd program to showcase our language's ability to compute common cs problems */
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
   print(gcd(45,120));
   return 0;
}