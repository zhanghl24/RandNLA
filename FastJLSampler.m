function Sampled_A =FastJLSampler(A, k)
    % INPUT:
    % A: matrix to be sampled
    % k: sample size
    D = randi([0, 1], 1, size(A, 1));
    index = find(D);
    A(index, :) = -A(index, :);
    temp = dct(A);
    Sampled_A = temp(randperm(size(A, 1), k), :) * sqrt(size(A, 1) / k);
end