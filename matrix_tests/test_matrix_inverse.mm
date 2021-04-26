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
  
/* Function to get adjoint of A[N, N] in adj[N, N]. */
def void adjoint(matrix<float> A, matrix<float> adj) {
    int N = getRows(A);
    if (N == 1) {
        adj[0, 0] = 1;
        return;
    }
    /* temp is used to store cofactors of A */
    int sign = 1;
    matrix<float> tmp = 
                    [0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.];
  
    for (int i=0; i<N; i=i+1)
    {
        for (int j=0; j<N; j=j+1)
        {
            /* Get cofactor of A[i, j] */
            getCofactor(A, tmp, i, j, N);
  
            /* sign of adj[j, i] positive if sum of row
               and column indexes is even. */
            if ((i + j) % 2 == 0) {
                sign = 1;
            } else{
                sign = -1;
            }
  
            /* Interchanging rows and columns to get the
               transpose of the cofactor matrix */
            adj[j, i] = (sign)*(determinant(tmp, N-1));
        }
    }
    
}
  
/* Function to calculate and store inverse, returns false if
   matrix is singular */
def int inverse(matrix<float> A, matrix<float> inverse) {
    /* Find determinant of A */
    int N = getRows(A);
    float det = determinant(A, N);
    if (det == 0) {
        return 1;
    }
  
    /* Find adjoint */
    matrix<float> adj = 
                    [0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.];
    adjoint(A, adj);
  
    /* Find Inverse using formula "inverse(A) = adj(A)/det(A)" */
    for (int i=0; i<N; i=i+1) {
        for (int j=0; j<N; j=j+1) {
            inverse[i, j] = adj[i, j]/det;
        }
    }
  
    return 0;
}

def int main() {
    /* declare matrix */
    matrix<float> A = [1., 2., 3., 4.;
                     2., 5., 6., 7.;
                     3., 6., 8., 9.;
                     4., 7., 9., 10.];

    /* declare result matrix */
   matrix<float> A_inv = 
                    [0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.;
                     0., 0., 0., 0.]; 

    /* compute invers/check if inverse is valid */
    if (inverse(A, A_inv) != 0) {
        print(-1);
    }
    printmf(A_inv);
    print(1111111111);
    printmf(A*A_inv);
}
