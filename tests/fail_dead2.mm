def int main(){
	int i;
	{
	int i = 12;
	return i;
	}
    i = 16; /* Fail: more code after a return */
}
