function AB = LeverageMatMul(A, B, k, n)
    % A refined version of RandMatMul, which reduces
    % approximation error by leverage sampling.
    % INPUT:
    % A, B: matrix to be producted
    % k: mample size
    % n: number of Monte Carlo
    % OUTPUT:
    % AB: an approximation of matrix product AB.

    embedding_size = ceil(2*size(B, 2));
    SB = SparseEmbeddingSampler(B, embedding_size);
    R = qr(SB, "econ");
    gaussian_sample_size = ceil(size(B, 2)/4);
    R_invG = (R \ randn(size(B, 2), gaussian_sample_size))/sqrt(gaussian_sample_size);
    q = sum(abs(B * R_invG).^2, 2);
    q = q / sum(q);
    
    AB = zeros(size(A, 1), size(B, 2));
    for iMonteCarlo = 1:n
        Sampled_B = zeros(k, size(B, 2));
        index = randsrc(1, k, [1:size(B, 1); q']);
        for i = 1:k
            Sampled_B(i, :) = B(index(i), :) / q(index(i));
        end
        Sampled_A = A(:, index);
        AB = AB + Sampled_A * Sampled_B / n / k;
    end
end