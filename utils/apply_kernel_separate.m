%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) Copyright 2013-17  MICC - Media Integration and Communication Center,
% University of Florence. Giuseppe Lisanti <giuseppe.lisanti@unifi.it> and
% Iacopo Masi <iacopo.masi@usc.edu> and Svebor Karaman <svebor.karaman@columbia.edu>.
% 
% If you use this code please cite BOTH the papers:
% @article{lisanti:mckcca:tomm17,
% author = {Lisanti, Giuseppe and Karaman, Svebor and Masi, Iacopo},
% title = {Multi Channel-Kernel Canonical Correlation Analysis for Cross-View Person Re-Identification},
% booktitle = {ACM Transactions on Multimedia Computing, Communications and Applications (TOMM)},
% year = {2017}, }
%
% @inproceedings{lisanti:icdsc14,
% author = {Lisanti, Giuseppe and Masi, Iacopo and {Del Bimbo}, Alberto},
% title = {Matching People across Camera Views using Kernel Canonical Correlation Analysis},
% booktitle = {Eighth ACM/IEEE International Conference on Distributed Smart Cameras},
% year = {2014}, }
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [D,omega] = apply_kernel_separate(X,Y,kernel,omega)
try, gpuDevice; useGPU=true; catch, useGPU=false; end

if nargin < 5
    omega = 0;
end

if strcmp('Linear',kernel)
    if useGPU
        X = gpuArray(double(X));
        Y = gpuArray(double(Y));
        D = gpuArray(zeros(size(X,2)));
    end
    D = (X'*Y);
    if useGPU
        D = gather(D);
    end
end

if strcmp('Gauss',kernel)
    if useGPU
        if nargin < 5
            [D,omega] = kernel_gpu_gauss(X',Y');
        else
            D = kernel_gpu_gauss(X',Y',omega);
        end
    else
        if nargin < 5
            [D,omega] = kernel_gauss(X',Y');
        else
            D = kernel_gauss(X',Y',omega);
        end
    end
end

if strcmp('ExpChi',kernel)
    if useGPU
        if nargin < 5
            [D,omega] = kernel_gpu_expchi2(X',Y');
        else
            D = kernel_gpu_expchi2(X',Y',omega);
        end
    else
        if nargin < 5
            [D,omega] = kernel_expchi2(X',Y');
        else
            D = kernel_expchi2(X',Y',omega);
        end
    end
end

if strcmp('Chi2',kernel)
    X = X./repmat(sum(X),size(X,1),1);
    Y = Y./repmat(sum(Y),size(Y,1),1);
    if useGPU
        D = kernel_gpu_chi2(X',Y');
    else
        D = kernel_chi2(X',Y');
    end
end