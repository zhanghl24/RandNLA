function Sampled_A = SparseEmbeddingSampler(A, k)
    % INPUT:
    % mode: 'c' for colomn sampling(right multiply)
    % and 'r' for row sampling(left multiply)
    % A: matrix to be sampled
    % k: sample size

    % S = zeros(k, size(A, 1));
    % for i = 1:size(A, 1)
    %     S(randi(k), i) = randi([-1, 1]);
    % end
    % S = sparse(S);
    % Sampled_A = S * A;
    Sampled_A = zeros(k, size(A, 2));
    for i = 1:size(A, 1)
        index = randi(k);
        Sampled_A(index, :) = Sampled_A(index, :)...
                                 + randi([-1, 1])*A(i, :);
    end
end