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

%% Creating Library Dir
if ~exist('lib','dir')
    mkdir lib
end
%% Downloading and Unzipping and Compiling LibLinear
if ~exist('lib/liblinear/','dir')
    disp('>Downloading and Unzipping liblinear');
    url_liblinear = 'http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/liblinear.cgi?+http://www.csie.ntu.edu.tw/~cjlin/liblinear+tar.gz';
    try
        untar(url_liblinear);
    catch ME
        if strcmp(ME.identifier,'MATLAB:untar:invalidTarFile')
            options = weboptions('CertificateFilename', '');
            outfilename = websave('./liblinear.tgz',url_liblinear,options);
            untar(outfilename);
        else
            rethrow(ME)
        end
    end
    list=dir('liblinear*');
    movefile(list(1).name,'lib/liblinear')
    disp('>liblinear ready.')
    disp('>now compiling liblinear...')
    run('lib/liblinear/matlab/make.m')
end
if ~exist('data','dir')
    mkdir data
end
%% Downloading the data
if ~exist('data/PRID_trials.mat','file')
    disp('Please manually download the trials from the link in the README')
    %disp('>Downloading and Unzipping Splits and Descriptors');
    %url_data='https://www.dropbox.com/s/ch9g4bymqyp7hi2/mck-ccareid_data.zip?dl=1';
    %try
    %    unzip(url_data);
    %catch ME
    %    if strcmp(ME.identifier,'MATLAB:unzip:invalidZipFile')
    %        options = weboptions('CertificateFilename', '');
    %        outfilename = websave('./mck-ccareid_data.zip',url_data,options);
    %        unzip(outfilename);
    %    else
    %        rethrow(ME)
    %    end
    %end
    %disp('>Splits and Descriptors ready.')
end

addpath('utils/');
addpath('lib/kcca_package');
addpath('lib/liblinear/matlab')

set(0,'DefaultFigureWindowStyle','docked');
colors = repmat('rgbkmcyrgbk',1,200);
