function [training_set, testing_set] = nFold_stratify(stratified_dataset, n)

%   Given the stratified observations per patient, we randomly select 
%   positive (a) and negative (b) patients and cut each class into n folds
%   to create 2 balanced training sets, each containing the feature values
%   and labels

% Edited by Shayan Monabbati
% Biomedical Engineering, Case Western Reserve University
% May 2019

%1. get indices of malignant and benign patients from 1-58
%2. take 1/3 of each and place in each fold
%% Shuffle the patients and separate positive and negative observations
    % commit a random portion of the dataset for training

    shuffled_patient_idx = randperm(length(stratified_dataset.Labels_Idx));    %randomize index for patients
    
    dataset = [];
    labels = [];
    idx = [];
    
    for i = 1:length(shuffled_patient_idx)
        dataset = [dataset; stratified_dataset.Feature_Values(shuffled_patient_idx(i),:)];
        labels = [labels; stratified_dataset.Patient_Labels(shuffled_patient_idx(i),:)];
        idx = [idx; stratified_dataset.Labels_Idx(shuffled_patient_idx(i),:)];
    end

    shuffled_mal_patients = [];
    shuffled_ben_patients = [];
    mal_values = {}; % positive observations
    ben_values = {}; % negative observations
    mal_labels = {};
    ben_labels = {};
    malcount = 0;
    bencount = 0;
    for p = 1:length(shuffled_patient_idx)
        if all(labels{p})
            malcount = malcount + 1;
            shuffled_mal_patients = [shuffled_mal_patients shuffled_patient_idx(p)];
            mal_values{malcount,1} = dataset{p};
            mal_labels{malcount,1} = idx{p};
        else
            bencount = bencount + 1;
            shuffled_ben_patients = [shuffled_ben_patients shuffled_patient_idx(p)];
            ben_values{bencount,1} = dataset{p};
            ben_labels{bencount,1} = idx{p};
        end
    end

%% Create n folds from combined positive and negative observations
    
    %remap missing patients to no gap index vector
    a_shuffle = 1:length(shuffled_mal_patients);    %same index
    b_shuffle = 1:length(shuffled_ben_patients);    %same index      

% define n sets
a_cuts = [0 round((1:n-1)/n*length(shuffled_mal_patients)) length(shuffled_mal_patients)];
b_cuts = [0 round((1:n-1)/n*length(shuffled_ben_patients)) length(shuffled_ben_patients)];
testing_set=cell(2,n);
training_set=cell(2,n);

for i=1:n
    a_ind = a_shuffle(a_cuts(i)+1:a_cuts(i+1));
    b_ind = b_shuffle(b_cuts(i)+1:b_cuts(i+1));
    %a_values = a(a_ind,:);
    %b_values = b(b_ind,:);
    a_values = [];
    a_notvalues = [];
    b_values = [];
    b_notvalues = [];
    %map patients back to dataset
    for j = a_shuffle
        if ismember(j,a_ind)
            a_values = [a_values; mal_values{j,1} mal_labels{j,1}];
        else
            a_notvalues = [a_notvalues; mal_values{j,1} mal_labels{j,1}];
        end
    end
    
    for k = b_shuffle
        if ismember(k,b_ind)
            b_values = [b_values; ben_values{k,1} ben_labels{k,1}];
        else
            b_notvalues = [b_notvalues; ben_values{k,1} ben_labels{k,1}];
        end
    end
    values = [a_values ; b_values];
    notvalues = [a_notvalues ; b_notvalues];
    
    % set testing set and labels
    testing_set{1,i} = values(:,1:end-1);
    testing_set{2,i} = values(:,end);
    
    % set training set as all samples not included in testing set
    training_set{1,i} = notvalues(:,1:end-1);
    training_set{2,i} = notvalues(:,end);

end
