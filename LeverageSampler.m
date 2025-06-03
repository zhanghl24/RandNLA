function Sampled_A = LeverageSampler(A, k)
    % INPUT:
    % A: matrix to be sampled
    % k: sample size

    embedding_size = ceil(2*size(A, 2));
    SA = SparseEmbeddingSampler(A, embedding_size);
    R = qr(SA, "econ");
    gaussian_sample_size = ceil(size(A, 2)/4);
    R_invG = (R \ randn(size(A, 2), gaussian_sample_size))/sqrt(gaussian_sample_size);
    % R_inv = inv(R);
    % R_invG = SparseSymbolSampler(R_inv', ceil(size(A, 2)/2));
    % R_invG = R_invG';
    q = sum(abs(A * R_invG).^2, 2);
    q = q / sum(q);

    Sampled_A = zeros(k, size(A, 2));
    index = randsrc(1, k, [1:size(A, 1); q']);
    for i = 1:k
        Sampled_A(i, :) = A(index(i), :) / sqrt(q(index(i))*k);
    end
end
