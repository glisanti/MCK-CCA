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

function [lr_model, lr_params, ind_to_rem] = cross_validate_c_bias(kcca_featAll,train_labelsAll,lr_params)

train_labelsAll_lr=train_labelsAll';
kcca_featAll_lr=sparse(kcca_featAll');
sizeTrain = size(train_labelsAll_lr,1);
nHalf=floor(sizeTrain/2);

accuras = zeros(size(lr_params.biasRange,2)*size(lr_params.cRange,2),1);
disp('Cross validating LR bias and C...')
[X,Y] = meshgrid(lr_params.cRange,lr_params.biasRange);
X = X(:);
Y = Y(:);

parfor i_bb=1:length(X)
    bb = Y(i_bb);
    cc = X(i_bb);
    %% First pass
    lr_model = train(train_labelsAll_lr(1:nHalf,:), kcca_featAll_lr(1:nHalf,:), [' -s ' num2str(lr_params.lr_type) ' -B ' num2str(bb) lr_params.quiet_switch ' -c ' num2str(cc)]);
    testMat_lr = sparse([kcca_featAll_lr(nHalf+1:end,:), bb.*ones(size(kcca_featAll_lr(nHalf+1:end,:),1),1)]);
    %% Getting the prediction from the model
    [~, accuracy1, prob1] = predict(double(train_labelsAll_lr(nHalf+1:end,:)), testMat_lr, lr_model,['-b 1 ' lr_params.quiet_switch]);
    %% Second pass
    lr_model = train(train_labelsAll_lr(nHalf+1:end,:), kcca_featAll_lr(nHalf+1:end,:), [' -s ' num2str(lr_params.lr_type) ' -B ' num2str(bb) lr_params.quiet_switch ' -c ' num2str(cc)]);
    testMat_lr = sparse([kcca_featAll_lr(1:nHalf,:), bb.*ones(size(kcca_featAll_lr(1:nHalf,:),1),1)]);
    %% Getting the prediction from the model
    [~, accuracy2, prob2] = predict(double(train_labelsAll_lr(1:nHalf,:)), testMat_lr, lr_model,['-b 1 ' lr_params.quiet_switch]);
    
    %% Store the mean accuracy
    accuras(i_bb) = (accuracy1(1)+accuracy2(1))/2.;
end

[~, idx] = max(accuras);
lr_params.bias = Y(idx);
lr_params.C = X(idx);
disp(['Found best bias as ' num2str(lr_params.bias) ' with best C as ' num2str(lr_params.C)])

%% Train the final model with cross validated bias
lr_model = train(train_labelsAll_lr, kcca_featAll_lr, [' -s ' num2str(lr_params.lr_type) ' -B ' num2str(lr_params.bias) lr_params.quiet_switch ' -c ' num2str(lr_params.C)]);
ind_to_rem = find(lr_model.w(1:end-1)<=0);
