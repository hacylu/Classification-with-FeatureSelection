function stats = nFold_BaggedC45_perPatient(data_set,data_labels,patient_labels,shuffle,n,nIter,Subsets)
% Using n-fold subset selection and C4.5 decision tree classifier
% Input:
%   data_set: data
%   data_labels: labels
%   patient_labels: labels from which we actually want to select training and testing subsets
%   shuffle: 1 for random, 0 for non-random partition (Default: 1)
%   n: Number of folds to your cross-validation (Default: 3)
%   nIter: Number of cross-validation iterations (Default: 1)
%   Subsets: pass your own training and testing subsets & labels (Default:
%   computer will generate using 'nFold')
%
% Output:
%   stats: struct containing TP, FP, TN, FN, etc.

% data_set = eigVec_graphfeats;
% data_labels = labels(:);
% classifier = 'SVM';
% shuffle = 1;
% n = 3;
if nargin < 7
    Subsets = {};
end
if nargin < 6
    nIter = 1;
end
if nargin < 5
    n = 3; % 3-fold cross-validation
end
if nargin < 4
    shuffle = 1; % randomized
end

if numel(unique(data_labels))~=3, error('Only 3 unique labels supported at this time.'); end
% if ~all(ismember(data_labels,[0 1 2])), error('Labels must be 0, 1, and 2.'); end
% if ~all(ismember(data_labels,[1 -1])), error('Labels must be 1 and -1'); end

% get unique patient labels and corresponding data labels
[unique_patient_labels, idx, ~] = unique(patient_labels,'first');
data_labels_perPatient = data_labels(idx);

stats = struct; %cell(1,nIter);
for j=1:nIter
    fprintf('Iteration: %i\n',j);
    
    % reset total statistics
    Ttp = 0; Ttn = 0; Tfp = 0; Tfn = 0; decision=zeros(size(data_labels)); prediction=zeros(length(data_labels),3);
    num_correct=0;
    
    if isempty(Subsets)
        [tra tes]=GenerateSubsets('nFold_multiclass',[],data_labels_perPatient,shuffle,n);
%         c = cvpartition(data_labels_perPatient,'kfold',n);
%         for i=1:n
%             tra{i} = training(c,i);
%             tes{i} = test(c,i);
%         end
    else
        tra = Subsets{j}.training;
        tes = Subsets{j}.testing;
    end
        
    for i=1:n
        fprintf(['Fold # ' num2str(i) '\n']);
        
        training_idx = ismember(patient_labels, unique_patient_labels(tra{i}));
        testing_idx = ismember(patient_labels, unique_patient_labels(tes{i}));

        training_set = data_set(training_idx,:);
        testing_set = data_set(testing_idx,:);
        training_labels = data_labels(training_idx);
        testing_labels = data_labels(testing_idx);

        [temp_stats,methodstring] = Classify( 'BaggedC45_multiclass', training_set , testing_set, training_labels, testing_labels);
%         Ttp = Ttp + temp_stats.tp;
%         Ttn = Ttn + temp_stats.tn;

        num_correct = num_correct + temp_stats.num_correct;
        decision(testing_idx) = temp_stats.decision;
        prediction(testing_idx,:) = temp_stats.prediction;
    end
%     decision(decision==0) = -1;
    
    % output statistics
%     stats(j).tp = Ttp;
%     stats(j).tn = Ttn;
%     stats(j).fp = Tfp;
%     stats(j).fn = Tfn;
    stats(j).acc = num_correct/length(data_labels);
%     stats(j).ppv = Ttp/(Ttp+Tfp);
%     stats(j).sens = Ttp/(Ttp+Tfn);
%     stats(j).spec = Ttn/(Tfp+Ttn);
    stats(j).subsets.training = tra;
    stats(j).subsets.testing = tes;
    stats(j).decision = decision;
    stats(j).prediction = prediction;
end