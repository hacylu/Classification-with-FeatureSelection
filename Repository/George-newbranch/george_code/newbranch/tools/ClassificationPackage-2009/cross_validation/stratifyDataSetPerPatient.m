function stratified_dataset = stratifyDataSetPerPatient(data_set, data_labels, patient_ids)

% input: data_set - mxn array of m observations and n number of features
%        data_labels - mx1 label vector with m observations
%        patient_ids - px1 vector with the corresponding first index to
%        your label vector as your patient ID
% output: struct with n patients; all observation feature values and labels for each patient

% Written by Shayan Monabbati
% Biomedical Engineering, Case Western Reserve University
% May 2019

stratified_dataset = struct();
stratified_dataset.Feature_Values = cell(length(patient_ids),1);
stratified_dataset.Patient_Labels = cell(length(patient_ids),1);
stratified_dataset.Labels_Idx = cell(length(patient_ids),1);

labels_index = (1:length(data_set))';
patient_id = 1;
    for i = 2:length(patient_ids)
        stratified_dataset.Feature_Values{patient_id,1} = data_set(patient_ids(i-1):patient_ids(i)-1,:);
        stratified_dataset.Patient_Labels{patient_id,1} = data_labels(patient_ids(i-1):patient_ids(i)-1);
        stratified_dataset.Labels_Idx{patient_id,1} = labels_index(patient_ids(i-1):patient_ids(i)-1);
        patient_id = patient_id + 1;
    end
% last patient
stratified_dataset.Feature_Values{i,1} = data_set(patient_ids(i):length(data_set(:,1)),:);
stratified_dataset.Patient_Labels{i,1} = data_labels(patient_ids(i):end);
stratified_dataset.Labels_Idx{i,1} = labels_index(patient_ids(i):end);

save('stratified_dataset.mat','stratified_dataset');
end