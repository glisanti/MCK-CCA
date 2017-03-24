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

%% Startup file that downloads all the needed materials
startup

%% %%%%%%%% Matching Parameters %%%%%%%%%%%%%
datasetname = 'PRID';
params.kerString = {'Linear','Gauss','ExpChi','Chi2'};
params.distance = 'cosine';
params.plotON = 1;
%% %%%%%%%% KCCA params %%%%%%%%%%%%%
params.eta = 1;
params.kapa = 0.5;
%% %%%%%%%% Iterative LR params %%%%%%%%%%%%
lr_params.lr_type = 0;
lr_params.kcross = 2;
lr_params.C = 1; %Note: will be overwritten in the crossValidation
lr_params.bias = 6; % Note: will be overwritten in the crossValidation
lr_params.quiet_switch=' -q';
lr_params.biasRange = 1:2:500;
lr_params.cRange = [0.01 0.05 0.1 0.5 1 5 10 50 100]; 
%%%%%%%%%%%%%%%%%%%%

%% Fixing Random Seed for KcrossValidation
s = RandStream('mt19937ar','Seed',0);
RandStream.setGlobalStream(s);
close all;

%% Descriptor ranges
% This values are used to slice the feature vector in order to access
% eahc specific channel. See our paper for more details.
params.desc_rng = [
    1 1088; 1 320; 385 704; 769 1088; % HSf - HSu - HSm - HSl
    1089 2176; 1089 1408; 1473 1792; 1857 2176; % RGBf - RGBu - RGBm - RGBl
    2177 3264; 2177 2496; 2561 2880; 2945 3264; % LABf - LABu - LABm - LABl
    3265 4304; 4305 4624; 4625 4944; 4945 5264; % HOGf - HOGu - HOGm - HOGl
    5265 6482; 6483 6830; 6831 7178; 7179 7526; % LBPf - LBPu - LBPm - LBPl
    ];

%% Switch dataset
switchDataset

% Final CMC
cmc_kcca = zeros(num_gallery_cmc,3);
cmc_kcca(:,1) = 1:num_gallery_cmc;

%% Loop over trials
for nt=1:nTrial
    disp(['====== Trial # ' num2str(nt) '======' ]);
    %% Training and testing splits
    train_a = trials(nt).featAtrain;
    train_b = trials(nt).featBtrain;
    test_a = trials(nt).featAtest;
    test_b = trials(nt).featBtest;
        
    num_test = size(test_a,2);
    num_gallery = size(test_b,2);
    num_train = size(train_b,2);
    
    %% Permutation on Test set
    idxTrain1 = 1:num_train;
    idxTrain2 = idxTrain1;
    idxProbe = 1:num_test;
    idxGallery = 1:num_gallery;
    %idxProbe = randperm(num_test);
    %idxGallery = randperm(num_gallery);
    
    %% Accessing Train and Test
    test_a = test_a(:,idxProbe);
    test_b = test_b(:,idxGallery);
    train_a = train_a(:,idxTrain1);
    train_b = train_b(:,idxTrain2);
        
    %% Performing Iterative Logistic Regression (ILR) cross-validation
    %% in the training set (corresponding to Sect. 4 of our paper)
    [kcca_featAll, train_labelsAll, lr_model, minS, maxS, ind_to_rem, lr_params] = ...
        iterativeLR(train_a,train_b,num_train,idxTrain1,idxTrain2,params,lr_params);
    
    %% Looping over each channel of the descriptor
    for i1=1:size(params.desc_rng,1)
        rng = params.desc_rng(i1,:);
        %% Looping and applying each kernel (see apply_kernel)
        % Kernel type | Linear:1 | Gauss:2 | ExpChi2:3 | Chi2:4 |
        for i2=1:length(params.kerString)
            
            clear omegaA omegaB
            [train_b_ker,omegaB] = apply_kernel_separate(train_b(rng(1):rng(2),:),...
                train_b(rng(1):rng(2),:),params.kerString{i2});
            
            [train_a_ker,omegaA] = apply_kernel_separate(train_a(rng(1):rng(2),:),...
                train_a(rng(1):rng(2),:),params.kerString{i2});
            
            test_b_ker = apply_kernel_separate(test_b(rng(1):rng(2),:),...
                train_b(rng(1):rng(2),:),params.kerString{i2},omegaB);
            
            test_a_ker = apply_kernel_separate(test_a(rng(1):rng(2),:),...
                train_a(rng(1):rng(2),:),params.kerString{i2},omegaA);
                        
           %% Learning KCCA on the entire training set
            disp(['Learning KCCA [Desc ' num2str(i1) ': Kernel ' params.kerString{i2} ']']);
            [Wx, Wy, r] = kcanonca_reg_ver2(train_b_ker,train_a_ker,params.eta,params.kapa,0,0);
                        
           %% Centering KCCA Test
            center_kcca
                        
           %% Projecting test
            tstart_proj = tic;
            test_b_ker_proj = test_b_ker*(Wx.*repmat(r',size(Wx,1),1));
            test_a_ker_proj = test_a_ker*(Wy.*repmat(r',size(Wy,1),1));
            timings_proj_main{nt}(i1,i2) = toc(tstart_proj);
                        
           %% Compute KCCA cosine distance wrt TEST
            [score_kcca_cos{i1,i2}, ~ ,~ ] = scaledata(...
                double(pdist2(test_b_ker_proj,test_a_ker_proj,params.distance)), ...
                -1, 1, min(cell2mat(minS(i1,i2,:))), max(cell2mat(maxS(i1,i2,:))));
            
        end
    end
    
    %% Performing late fusion using ILR
    disp('Performing Fusion...');
    test_kcca_feat = cellfun(@(C) C(1:num_gallery,1:num_test), score_kcca_cos,'UniformOutput',false);
    kcca_feat_test = -reshape(cell2mat(test_kcca_feat(:)'),num_gallery*num_test,prod(size(score_kcca_cos)))';
    kcca_feat_test_orig = kcca_feat_test;
    %% Removing scores from dropped channels
    if ~isempty(ind_to_rem{1,1})
        for t_iter=1:size(ind_to_rem,1)
            kcca_feat_test(ind_to_rem{t_iter,1},:)=[];
            disp(['Removed ' num2str(length(ind_to_rem{t_iter,1})) ' elements'])
        end
    end
    
    %%%%%%%%%% EVALUATION PART %%%%%%%%%%%%%%%%%%%
    
    %% Getting labels on the test
    testing_labels = pdist2(idxProbe',idxGallery',@(Xi,Xj) single(Xi==Xj))';
    testing_labels = testing_labels(:);
    
    %% Testing Data matrix
    testMat = sparse([kcca_feat_test', lr_params.bias.*ones(size(kcca_feat_test',1),1)]);
    
    %% Getting the prediction from the ILR model
    [predicted_label, accuracy, prob_estimates] = predict(double(testing_labels), testMat, lr_model,'-b 1');  
    score_kcca = reshape(prob_estimates(:,1),num_gallery,num_test);
    
    %% Computing CMC
    idxProbe = trials(nt).labels_probe(idxProbe);
    idxGallery = trials(nt).labels_gallery(idxGallery);
    [cmcCurrent, cmc_kcca] = computeCMC(score_kcca,length(idxGallery),length(idxProbe),idxProbe,idxGallery,cmc_kcca);
    disp(['Rank-1 cmc_kcca: ' num2str(cmc_kcca(1,2)/cmc_kcca(1,3)*100)]);
    
end

disp('Finished')

%% Final CMC and Plot
if params.plotON
    figure(1);hold on;plotCMCcurve(cmc_kcca,'b','',[datasetname ' Final Result']);
    legend('KCCA','Location','SouthEast');
end
