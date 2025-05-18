def num_of_paths_to_dest(n: int) -> int:
    matrix = [[0]*n]*n
    matrix[0][0] = 1
    for i in range(n):
        for j in range(n):
            if i<j:
                if j == 0:
                    matric[i][j] = matrix[i-1][j]
                else:
                    matrix[i][j] = matrix[i-1][j] + matrix[i][j-1]
    return matrix[n-1][n-1]
