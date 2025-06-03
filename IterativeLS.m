function x = IterativeLS(A, b, epsilon, k)
    % This function solves the least-square problem
    % Ax=b in an iterative, randomlized manner.
    
    % INPUT:
    % epsilon: terminate condition
    % k: sample size in each iteration
    % OUTPUT:
    % x: an approximation solution of Ax=b
    f = @FastJLSampler;
    r = b;
    x = zeros(size(A, 2), 1);
    while norm(r) > epsilon
        SA = RandomSamping('r', f, A, k);
        increment = quadprog(SA'*SA , -A'*r);
        if norm(increment) < epsilon
            break
        end
        x = x + increment;
        r = b - A*x;
        norm(r)
    end
end