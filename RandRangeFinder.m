function Q = RandRangeFinder(A, epsilon, k_interval)
    % This function finds a set of basis for
    % the colomn space of matrix A by Monte Carlo Method.
    % Note that the random sample Y=AS and A shares the same
    % colomn space as long as the sample size k is greater than 
    % rank(A). When the rank is not known in advance, 
    % we adjust sample size by binary search in an tolarence
    % interval [kmin, kmax].

    % INPUT:
    % A: matrix of size m×n, with rank r<n
    % epsilon: the reconstruction error
    % k_interval: the tolarence interval [kmin, kmax] of sample size k.
    % OUTPUT:
    % Q: colomn orthogonal matrix, whose colomns
    % is a set of basis for the colomn space of 
    % matrix A.

    kmin = k_interval(1);
    kmax = k_interval(2);
    tolarence = ceil((kmax-kmin)/64);
    k = kmin;
    f = @FastJLSampler;
    s = 5; %sample size for posterior check
    while kmax-kmin > tolarence % set a loose terminate condition to
                         % reduce iteration number
        Y = RandomSamping('c', f, A, k);
        [Q, ~] = qr(Y, 'econ');
        test = A*randn(size(A, 2), s);
        test_weight = Q'*test;
        test = test - Q*test_weight;
        test = sum(test.^2, "all") / s;
        if test < epsilon
            kmax = k;
        else 
            kmin = k;
        end
        k = ceil((kmin+kmax)/2);
    end
end