% KERNEL_EXPCHI2: Compute a Gaussian Kernel
% distances.
%
% Usage:  [D,md] = kernel_gauss(X,Y,[omega])
%
% Input:  X,Y are the two set of features; omega is the parameter of the
%         exp kernel (if not specified omega is computed as the mean of the
%         distances among the training examples)
% Output: D is the Kernel matrix; md is the mean of the distances among the
%         training examples
%
% written by Lamberto Ballan (lamberto.ballan@unifi.it)
%            Tiberio Uricchio (tiberio.uricchio@unifi.it)
% University of Florence, 04/11/2013

function [D,md] = kernel_gauss(X,Y,omega)
  
  D = zeros(size(X,1),size(Y,1));
  
  for i=1:size(Y,1)
    d = bsxfun(@minus, X, Y(i,:));
    D(:,i) = sqrt(sum(d.^2, 2));
  end
	
  md = median(D(:));
  
  if nargin < 3
    omega = md;
  end
	
  D = exp( - 1./omega .* D);
  D = gather(D);
  md = gather(md);
  
end
