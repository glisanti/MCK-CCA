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

function [kcca_featAll, train_labelsAll, lr_model, minS, maxS, ind_to_rem, lr_params] = iterativeLR(train_a,train_b,num_train,idxTrain1,idxTrain2,params,lr_params)

%% Initialization Cross fold
idx = crossvalind('Kfold', num_train, lr_params.kcross);

train_labelsAll = [];
kcca_featAll = [];

%% Looping over each "channel" of the descriptor
for kk=1:lr_params.kcross
    disp(['> Fold # ' num2str(kk)])
    idxTest = idx == kk;
    
    for i1=1:size(params.desc_rng,1)
        rng = params.desc_rng(i1,:);
        %% Looping and applying each kernel (see apply_kernel)
        % Kernel type | Linear:1 | Gauss:2 | ExpChi2:3 | Chi2:4 |
        for i2=1:length(params.kerString)
            
            idxTestNum_lr = find(idxTest);
            idxTrainNum_lr = find(~idxTest);
            
            train_b_lr = train_b(:,idxTrainNum_lr);
            train_a_lr = train_a(:,idxTrainNum_lr);
            test_b_lr = train_b(:,idxTestNum_lr);
            test_a_lr = train_a(:,idxTestNum_lr);
            
            clear omegaA omegaB
            [train_b_ker_lr,omegaB] = apply_kernel_separate(train_b_lr(rng(1):rng(2),:),...
                train_b_lr(rng(1):rng(2),:),params.kerString{i2});
            
            [train_a_ker_lr,omegaA] = apply_kernel_separate(train_a_lr(rng(1):rng(2),:),...
                train_a_lr(rng(1):rng(2),:),params.kerString{i2});
            
            test_b_ker_lr = apply_kernel_separate(test_b_lr(rng(1):rng(2),:),...
                train_b_lr(rng(1):rng(2),:),params.kerString{i2},omegaB);
            
            test_a_ker_lr = apply_kernel_separate(test_a_lr(rng(1):rng(2),:),...
                train_a_lr(rng(1):rng(2),:),params.kerString{i2},omegaA);
            
           %% Learning KCCA for this Training fold
            disp(['Learning KCCA [Desc ' num2str(i1) ': Kernel ' params.kerString{i2} ']']);
            [Wx, Wy, r] = kcanonca_reg_ver2(train_b_ker_lr,train_a_ker_lr,params.eta,params.kapa,0,0);
            
            %% Center KCCA hold-out fold
            center_kcca_lr
            
            %disp(['Project train and test [Desc ' num2str(i1) ': Kernel ' params.kerString{i2} ']']);
            % Project test
            test_b_ker_proj_lr = test_b_ker_lr*(Wx.*repmat(r',size(Wx,1),1));
            test_a_ker_proj_lr = test_a_ker_lr*(Wy.*repmat(r',size(Wy,1),1));
            
            %% Compute KCCA cosine distance wrt hold-out fold
            [score_kcca_train_held{i1,i2}, minS{i1,i2,kk}, maxS{i1,i2,kk}] = ...
                scaledata(double(pdist2(test_b_ker_proj_lr,test_a_ker_proj_lr,params.distance)),-1,1);            
        end
    end
    
    
    %% Learning LR
    num_samples = size(score_kcca_train_held{i1,i2},1);
    [mesh_a,mesh_b] = meshgrid(1:num_samples, 1:num_samples);
    pairs = [mesh_a(:) mesh_b(:)];
    pairs_ids=[idxTrain1(pairs(:,1))',idxTrain2(pairs(:,2))'];
    train_labels = double(pairs_ids(:,1)==pairs_ids(:,2));
    
    tmp_kcca_feat_lr = cellfun(@(C) C(1:num_samples,1:num_samples), score_kcca_train_held,'UniformOutput',false);
    kcca_feat_lr = reshape(cell2mat(tmp_kcca_feat_lr(:)'),num_samples*num_samples,prod(size(score_kcca_train_held)))';
    
    train_labelsAll = [train_labelsAll train_labels'];
    kcca_featAll = [kcca_featAll kcca_feat_lr];
end

cr_iter_num = 10;
cr_iter = 1;
cr_iter_exit = 0;
ind_to_rem{cr_iter,1} = [];
%% Performing Iterative Logistic Regression
%% This will drop out unuseful channels
while ~cr_iter_exit
    
    [lr_model, lr_params, ind_to_rem_tmp] = cross_validate_c_bias(-kcca_featAll,train_labelsAll,lr_params);
      
    if ~isempty(ind_to_rem_tmp) && cr_iter <= cr_iter_num
        kcca_featAll(ind_to_rem_tmp,:) = [];
        ind_to_rem{cr_iter,1} = ind_to_rem_tmp;
        cr_iter = cr_iter+1;
    else
        cr_iter_exit = 1;
    end
end