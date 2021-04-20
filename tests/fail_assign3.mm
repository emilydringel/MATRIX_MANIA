def void testvoid(){
	return;
}
def int main(){
	int i;
	i = testvoid(); /* Fail: assigning a void to an int */
}
