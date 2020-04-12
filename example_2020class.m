addpath(genpath(pwd)); % add dependency path

load example_data.mat
%% 1**** try different classifier and feature combination in cross validation
para.intFolds=3;
para.intIter=10;
para.num_top_feature=3;
para.get_balance_sens_spec=1;
para.balanced_trainset=1;

% para.set_classifier={'LDA','BaggedC45'};
% para.set_featureselection={'ttest','mrmr'};

para.set_classifier={'LDA','QDA','BaggedC45'};
para.set_featureselection={'wilcoxon','ttest','mrmr'};

para.correlation_factor=0.9;

% -data should be a m x n matrix, in which m is the patient number and n is
% the feature number
% -labels is a vector to indicate the outcome, normally set to 0 or 1
% 
labels = classes;
feature_list=ones(1,size(data,2));%dummy one if unavaliable
[resultACC,resultAUC,result_feat_ranked,result_feat_scores,result_feat_idx_ranked]=Leveluate_feat_using_diff_classifier_feature_selection(data,labels,feature_list,para);
T=Lget_classifier_feature_slection_performance_table(resultACC,resultAUC,para);

look at T to see your result !!
%% 2**** if you want to use leave one out to get the predicted labels, use the code below
para.featureranking='mrmr';
para.num_top_feature=5;
para.classifier_name='LDA';
para.T_on_predicted_pro=0.5;
para.feature_selection_mode='cross-validation';%'one-shot'; %
para.feature_list=feature_list;

[labels_pred,probability_pred,result]=Lgenerate_Predicted_Label_leave_one_out(data,labels,para);
