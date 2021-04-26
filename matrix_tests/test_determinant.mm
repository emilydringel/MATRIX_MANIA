/* Algorithms modified from https://www.geeksforgeeks.org/adjoint-inverse-matrix/ */

/* Function to get cofactor of A[p,q] in temp. 
   n is current dimension of A */
def void getCofactor(matrix<float> A , matrix<float> temp, int p, int q, int n ) {
    int i = 0;
    int j = 0;
  
    /* Looping for each element of the matrix */
    for (int row = 0; row < n; row = row + 1) {
        for (int col = 0; col < n; col = col + 1) {
            /*  Copying into temporary matrix only those element
                which are not in given row and column */
            if (row != p && col != q){
                temp[i, j] = A[row, col];
                j = j + 1;
  
                /*  Row is filled, so increase row index and
                    reset col index */
                if (j == n - 1) {
                    j = 0;
                    i = i+1;
                }
            }
        }
    }
}

/* Recursive function for finding determinant of matrix.
   n is current dimension of A. */
def float determinant(matrix<float> A, int n) {
    float D = 0;
  
    /*  Base case : if matrix contains single element */
    if (n == 1) {
        return A[0, 0];
    }

    matrix<float> tmp = 
                    [0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.];
  
    int sign = 1;  /* To store sign multiplier */
  
     /* Iterate for each element of first row */
    for (int f = 0; f < n; f=f+1) {
        /* Getting Cofactor of A[0, f] */
        getCofactor(A, tmp, 0, f, n);
        D = D + sign * A[0, f] * determinant(tmp, n - 1);
  
        /* terms are to be added with alternate sign */
        sign = -sign;
    }
  
    return D;
}

def int main(){
    matrix<float> A = [1., 2., 3., 4.;
                     2., 5., 6., 7.;
                     3., 6., 8., 9.;
                     4., 7., 9., 10.];
	float d = determinant(A, 4);
	printf(d);	
}
