function [U, S, V] = RandomSVD(RangeFinder, arg1, arg2, arg3)
    % This function calculate the approximated 
    % singular decomposition of a matrix. 
    % INPUT:
    % RangeFinder: a handle of a certain rangefinder function
    % arg1~arg3: args of the rangefinder

    Q = RangeFinder(arg1, arg2, arg3);
    C = Q' * arg1;
    [U, S, V] = svd(C, 'econ');
    U = Q * U;
end