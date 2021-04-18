/*def int main(){
    printm([1,2,3;4,5,6]);
}
*/
void printm(int* element_one);

int main(){
    int x = 7;
    int matrix[8] = {2,3,1+4,x+3,3,4,5,6};
    printm(matrix);
    return 0;
}