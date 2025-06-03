function Sampled_A = SparseSymbolSampler(A, k)
    % INPUT:
    % mode: 'c' for colomn sampling(right multiply)
    % and 'r' for row sampling(left multiply)
    % A: matrix to be sampled
    % k: sample size

    d = min(ceil(k/2), 8);
    % d: sample density (8 for default)
    S = zeros(k, size(A, 1));
    for i = 1:size(A, 1)
        S(randperm(k, d), i) = 1;
    end
    S = sparse(S);
    Sampled_A = S * A / sqrt(d);
end