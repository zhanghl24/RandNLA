function Sampled_A = GaussianSampler(A, k)
    % INPUT:
    % A: matrix to be sampled
    % k: sample size
    S = randn(k, size(A, 1));
    Sampled_A = S * A / sqrt(k);
end

 