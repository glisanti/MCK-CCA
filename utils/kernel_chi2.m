% KERNEL_EXPCHI2: Compute a Kernel using Chi-Square distances.
%
% Usage:  [D,md] = kernel_chi2(X,Y)
%
% Input:  X,Y are the two set of features;
%         distances among the training examples)
% Output: D is the Kernel matrix; md is the mean of the distances among the
%         training examples
% 
% written by Lamberto Ballan (lamberto.ballan@unifi.it)
% University of Florence, 11/05/2013

function D = kernel_chi2(X,Y)

D = zeros(size(X,1),size(Y,1));
parfor i=1:size(Y,1)
    d = bsxfun(@minus, X, Y(i,:));
    s = bsxfun(@plus, X, Y(i,:));
    D(:,i) = sum(d.^2 ./ (s/2+eps), 2);
end
D = 1 - D;

end
