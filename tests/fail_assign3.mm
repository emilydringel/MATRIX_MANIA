def void testvoid(){
	int p = 1; 
}
def int main(){
	int i = testvoid(); /* Fail: assigning a void to an int */
}

