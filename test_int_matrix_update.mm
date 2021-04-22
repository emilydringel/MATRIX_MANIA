def int main(){
  matrix<int> m = [1,3,5,7;2,4,6,8];
  printm(m);
  int r = getRows(m);
  int c = getColumns(m);
  /* subtract one to each element of matrix */
  int row_idx = 0;
  while (row_idx < r) {
    int col_idx = 0;
    while (col_idx < c) {
      m[row_idx, col_idx] = m[row_idx, col_idx] - 1;
      col_idx = col_idx + 1;
    }
    row_idx = row_idx + 1;
  }
  printm(m);
}
