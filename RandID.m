function [C, X]= RandID(A, r, p)
    % This function factorizes the input matrix A
    % into a submatrix C and an interpolation matrix
    % X, where colomns of C is part of colomns of A. 
    % A ≈ CX.

    % INPUT:
    % A: matrix to be factorized
    % r: estimation of rand(A) in advance
    % p: oversampling coefficient
    % OUTPUT:
    % C, X: ID(Interpolation Decomposition) components
    
    k = r + p; % k: number of colomns in C
    f = @FastJLSampler;
    sampling_size = ceil(1.2*r);
    Y_remain = RandomSamping('r', f, A, sampling_size);
    remain_index_table = 1:size(A, 2);
    Q = zeros(sampling_size, k);
    selected_index_list = zeros(1, k);
    selected_index = 1;
    selected_index_list(1) = selected_index;
    for i = 1:k-1
        Q(:, i) = Y_remain(:, selected_index) / norm(Y_remain(:, selected_index));
        Y_remain = [Y_remain(:, 1:selected_index-1), ...
                    Y_remain(:, selected_index+1:end)];
        remain_index_table = [remain_index_table(1:selected_index-1),...
                              remain_index_table(selected_index+1:end)];
        Y_weight = Q(:, i)' * Y_remain;
        [~, selected_index] = min(sum(Y_weight.^2, 1));
        selected_index_list(i+1) = remain_index_table(selected_index);
        Y_remain = Y_remain - Q(:, i) * Y_weight;
    end
    C = A(:, selected_index_list);
    X = C \ A;
end
        




        
        

