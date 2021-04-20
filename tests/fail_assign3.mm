def void testvoid(){
	return;
}
def int main(){
	int i = testvoid(); /* Fail: assigning a void to an int */
}

