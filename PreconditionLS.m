function x = PreconditionLS(A, b, k)
    % This function solves the least-square problem
    % Ax=b by preconditioning.

    f = @FastJLSampler;
    Y = RandomSamping('r', f, A, k);
    [~, R] = qr(Y, 'econ');
    %A_conditioned = A / R;
    x = lsqr(A, b, 1e-3, 20, R);
    %x = R \ x;
end
