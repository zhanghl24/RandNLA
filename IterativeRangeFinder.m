function Q = IterativeRangeFinder(A, epsilon, r)
    % This function finds a set of basis for
    % the colomn space of matrix A.
    % INPUT: 
    % A: matrix of size m×n, with rank r<n
    % epsilon: the reconstruction error, 
    % or the energy of A outside the colomn
    % space of output Q
    % r: number of test vectors
    % OUTPUT:
    % Q: colomn orthogonal matrix, whose colomns
    % is a set of basis for the colomn space of 
    % matrix A.
    Q = zeros(size(A));
    f = @FastJLSampler;
    Y = RandomSamping('c', f, A, size(A, 2));
    i = 0;
    while sqrt(max(sum(Y(:, i+1:i+r).^2, 1))) > epsilon/(10*sqrt(2/pi))...
            & i < size(A, 2)
        y = Y(:, i+1);
        q = y / norm(y);
        i = i+1;
        Q(:, i) = q;
        Y(:, i+r) = Orth(Q(:, 1:i), Y(:, i+r)); % main complexity
        Y_weight = q'*Y(:, i+1:i+r);
        Y(:, i+1:i+r) = Y(:, i+1:i+r) - q*Y_weight;
    end
    Q = Q(:, 1:i);
end

function y_ = Orth(Q, y)
    % This function return (I-QQ^T)y for any 
    % colomn orthogonal matrix Q and vector y.
    if isempty(Q)
        y_ = y;
    else 
        c = Q'*y;
        y_p = Q*c; % Projection
        y_ = y - y_p;
    end
end