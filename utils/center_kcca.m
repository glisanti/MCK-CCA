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

l =size(train_b_ker, 1);
j = ones(l,1);
test_b_ker = test_b_ker - (ones(size(test_b_ker))*train_b_ker) / l - (test_b_ker*(j*j'))/l +((j'*train_b_ker*j)*ones(size(test_b_ker)))/(l^2);

l =size(train_a_ker, 1);
j = ones(l,1);
test_a_ker = test_a_ker - (ones(size(test_a_ker))*train_a_ker) / l - (test_a_ker*(j*j'))/l +((j'*train_a_ker*j)*ones(size(test_a_ker)))/(l^2);
