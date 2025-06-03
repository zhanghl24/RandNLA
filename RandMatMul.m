function AB = RandMatMul(A, B, k, n)
    % This function calculate an approximation of the
    % matrix product A * B.
    % INPUT:
    % A, B: Matrix to be producted
    % k: sample size
    % n: number of Monte Carlo
    % OUTPUT:
    % AB: an approximation of matrix product AB.
    
    AB = zeros(size(A, 1), size(B, 2));
    for iMonteCarlo = 1:n
        Sampled_B = zeros(k, size(B, 2));
        index = randi(size(B, 1), 1, k);
        for i = 1:k
            Sampled_B(i, :) = B(index(i), :);
        end
        Sampled_A = A(:, index);
        AB = AB + Sampled_A * Sampled_B / n / k * size(B, 1);
    end
end