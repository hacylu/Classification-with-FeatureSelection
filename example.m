
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

%% %%%%%%%%%%%%%%%%test these groups of features in terms of mean AUC, for all eipstroma combined classifiers C_epistroma
% set_feature_group_name={'basicgraph','morph','CGT','CCG','BS','BSinCCG','CRL','fractal','oriCCM','CCM','FeDeG'};
set_feature_group_name={'basicgraph','morph','CGT','CCG','BS','BSinCCG','CRL','HarralickNuWise','cCCM48','cCCM44','CCM48','FeDeG'};
labels=label_HG_LG;
index_POI_indata_all=~isnan(labels);

set_feature_group_meanAUC=[];
set_feature_group_scores=[];% record the feature score within each feature group
set_feature_group_result=[];% record the AUC within each feature group
set_feature_group_top_feature_idx=[];
set_feature_group_top_feature_names=[];

num_top_feature=4;

para.feature_score_method='addone';
% para.classifier='LDA';
para.classifier='LDA';
% para.classifier='BaggedC45';
para.featureranking='wilcoxon';
para.correlation_factor=.9;
para.balanced_trainset=0;
para.get_balance_sens_spec=1;
intIter=10;%run number
intFolds=3;%fold number
num_top_features2keepinrecord=30;% top features keep in record
% sum(isnan(cur_data));

for i=1:length(set_feature_group_name)
    cur_feature_group=set_feature_group_name{i};
    cur_data=eval(sprintf('data_%s',cur_feature_group));
    cur_feature_list=eval(sprintf('feature_list_%s',cur_feature_group));
    if ~strcmp(cur_feature_group,'fractal')
         para.num_top_feature=num_top_feature;
         [set_feature_group_result{i},set_feature_group_scores{i}] = nFold_AnyClassifier_withFeatureselection_v5( cur_data(index_POI_indata_all,:),...
             labels(index_POI_indata_all), cur_feature_list,para,1,intFolds,intIter);
         cur_score=set_feature_group_scores{i};
         [val,idx]=sort(cur_score,'descend');
         set_feature_group_top_feature_idx{i}=idx(1:num_top_features2keepinrecord);
         set_feature_group_top_feature_names{i}=cur_feature_list(idx(1:num_top_features2keepinrecord))';
    else
        para.num_top_feature=min(num_top_feature,3);
        [set_feature_group_result{i},set_feature_group_scores{i}] = nFold_AnyClassifier_withFeatureselection_v5( cur_data(index_POI_indata_all,:),...
            labels(index_POI_indata_all), cur_feature_list,para,1,intFolds,intIter);
        cur_score=set_feature_group_scores{i};
        [val,idx]=sort(cur_score,'descend');
        set_feature_group_top_feature_idx{i}=idx(1:para.num_top_feature);
        set_feature_group_top_feature_names{i}=cur_feature_list(idx(1:para.num_top_feature))';
    end
    set_feature_group_meanAUC(i)=mean([set_feature_group_result{i}.AUC]);
end
%% check the top features in each feature family
idx_good_family=find(set_feature_group_meanAUC>0.59);
set_feature_group_top_feature_idx_good=set_feature_group_top_feature_idx(idx_good_family);
set_feature_group_top_feature_names_good=set_feature_group_top_feature_names(idx_good_family);
%%% plot out the top features, each family has one figure
set_feature_group_name_good=set_feature_group_name(idx_good_family);

addpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Miscellaneous\violin_plots\Violinplot-Matlab-master');

figure(11);

for i=1:length(set_feature_group_name_good) 
    cur_feature_group=set_feature_group_name_good{i};
    for j=1:num_top_feature
        subplot(length(set_feature_group_name_good),num_top_feature,num_top_feature*(i-1)+j);
        curfeatidx=set_feature_group_top_feature_idx_good{i};
        
        cur_data=eval(sprintf('data_%s',cur_feature_group));
        curfeat=cur_data(:,curfeatidx(j));
        curfeat_valid=curfeat(index_POI_indata_all);
        label_valid=logical(labels(index_POI_indata_all));
        vs = violinplot(curfeat_valid, label_valid);
        ylabel(set_feature_group_top_feature_names_good{i}{j});
        
        % misc

%         [h,p]=ttest2(v_PCA(group==1),v_PCA(group==2));
        [p,~] = ranksum(curfeat_valid(label_valid),curfeat_valid(~label_valid));
        if p>0.00001
            xlabel(sprintf('N=%d, p=%f',length(label_valid),p));
        else
            xlabel(sprintf('N=%d, p<0.00001',length(label_valid)));
        end
%         xlim([0.5, 7.5]);

%         set(h,{'linew'},{2});
        set(gca,'FontSize',12);
%         set(findobj(gca,'Type','text'),'FontSize',50,'fontweight','bold');
    end
end

%% 3****build classifiers using selected features from training set
%%% build the final classifer using QDA

T_predict=0.5; % threshold on the predicted probability obtain by the classifier

% data_validation - is the data from validation set, in which the feature
% dimension is the same as the the training data (only keep the slected features)
% labels - is a vector, with 0 and 1
try 
    [~,~,probs,~,c] = classify(data_validation,data_train,labels,'quadratic'); 
catch err
    [~,~,probs,~,c] = classify(data_validation,data_train,labels,'diagquadratic'); 
end
label_qda=zeros(size(data_validation,1),1);
label_qda(probs(:,2)>T_predict)=1;
% sum(label_qda)


%%% build the final classifer using LDA
try 
    [~,~,probs,~,c] = classify(data_validation,data_train,labels,'linear'); 
catch err
    [~,~,probs,~,c] = classify(data_validation,data_train,labels,'diaglinear'); 
end

label_lda=zeros(size(data_validation,1),1);
label_lda(probs(:,2)>T_predict)=1;
% sum(label_lda)


%%% build the final classifer using RF
data_train=good_featuregroup_data;
data_validation=good_featuregroup_data;
methodstring = 'BaggedC45';
options = statset('UseParallel','never','UseSubstreams','never');
C_rf = TreeBagger(50,data_train,labels,'FBoot',0.667,'oobpred','on','Method','classification','NVarToSample','all','NPrint',4,'Options',options);    % create bagged d-tree classifiers from training

[Yfit,Scores] = predict(C_rf,data_validation);   % use to classify testing
% [Yfit,Scores] = predict(C_rf,data_train);   % use to classify testing
label_lda=str2double(Yfit);
% sum(label_lda)
% accuracy_RF_reuse=sum(label_lda==labels')/length(labels);

%% 4**** check the classification perfromance in test set
[recall,specificity,accuracy]=Lcal_recall_spe_acc(groundtruth_label,predicted_label);

%% 5**** check the KM curve
