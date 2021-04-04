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
 printf(gcd(3, 15));
 return 0;
}
