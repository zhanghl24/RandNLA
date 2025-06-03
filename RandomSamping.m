function Sampled_A = RandomSamping(mode, Sampler, A, k)
    % INPUT:
    % mode: 'r' for row sampling (left multiplex) and 
    %       'c' for colomn sampling (right multiplex)
    % Sampler: a certain sample function corresponding to 
    %          a specified sampling method
    % A: matrix to be sampled
    % k: sample size
    if mode == 'r'
        Sampled_A = Sampler(A, k);
    elseif mode == 'c'
        Sampled_A = (Sampler(A', k))';
    else
        disp("No such mode")
    end
end
    