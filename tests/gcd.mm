int gcd(int x, int y){ 
 while(x != y){
   if(x > y) 
      x = x - y;
   else
      y = y - x;
}
return x;
}

def main ( ){
 print(gcd(3, 15));
 print(gcd(18,24));
 return 0;
}
