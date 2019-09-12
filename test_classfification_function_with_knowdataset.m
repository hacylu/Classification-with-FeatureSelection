load fisheriris
gscatter(meas(:,1), meas(:,2), species,'rgb','osd');
xlabel('Sepal length');
ylabel('Sepal width');
N = size(meas,1);

idx1=strfind(species,'versicolor');
idx11=zeros(length(idx1),1);

for i=1:length(idx1)
   cur=idx1{i};
   if ~isempty(cur)
       idx11(i)=1;
   end
end

idx2=strfind(species,'virginica');
idx22=zeros(length(idx2),1);

for i=1:length(idx2)
   cur=idx2{i};
   if ~isempty(cur)
       idx22(i)=1;
   end
end

data_t=meas(idx11|idx22,:);
labels_t=zeros(100,1);
labels_t(1:50)=1;
feature_list_dummy=1:4;
para_t=para;
para_t.intFolds=5;
para_t.intIter=10;
para.num_top_feature=3;
para.balanced_trainset=1;
[resultACC,resultAUC,result_feat_ranked,result_feat_scores,result_feat_idx_ranked]=Leveluate_feat_using_diff_classifier_feature_selection_v2(data_t,double(labels_t),...
    feature_list_dummy,para_t);
T_LH=Lget_classifier_feature_slection_performance_table(resultACC,resultAUC,para);
