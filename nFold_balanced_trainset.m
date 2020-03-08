function [training, testing] = nFold_balanced_trainset(data_set, data_labels, shuffle, n)

data_labels = data_labels(:);

% 1. First, we acquire the training set, training labels, testing set and testing labels.
%    For this, we will divide our data set in two. We will find positive (a)
%    and negative (b) examples to create a balanced training set.

% [label_train, label_val]=LsplitData2Train_Val(labels_all,percentage_of_minority_in_val,shuffle)

a = find( data_labels >  0 );
b = find( data_labels <= 0 );

if shuffle
    % commit a random portion of the dataset for training
    a_shuffle = randperm(length(a));    %randomize index
    b_shuffle = randperm(length(b));    %randomize index
else
    % or don't shuffle
    a_shuffle = 1:length(a);    %same index
    b_shuffle = 1:length(b);    %same index
end

% determin the minority class

minority_size=min(length(a),length(b));
manority_size=max(length(a),length(b));

fold_size_minority=round(minority_size/n);

% if it's too skew we make it balanced
if manority_size/minority_size>1.1
    % define n sets
    a_cuts = 0:fold_size_minority:size(a,1);
    b_cuts = 0:fold_size_minority:size(b,1);
    
    if length(a_cuts)>length(b_cuts)
        a_cuts = [0 round((1:n-1)/n*length(a)) size(a,1)];
        b_cuts = [b_cuts size(b,1)];
    else
        b_cuts = [0 round((1:n-1)/n*length(b)) size(b,1)];
        a_cuts = [a_cuts size(a,1)];
    end
else
    a_cuts = [0 round((1:n-1)/n*length(a)) size(a,1)];
    b_cuts = [0 round((1:n-1)/n*length(b)) size(b,1)];
end

testing=cell(1,n);
training=cell(1,n);
a_tmp=testing;
b_tmp=training;
a_tmp_remaining=a_tmp;
b_tmp_remaining=a_tmp;
for i=1:n
    if length(a)>=length(b)
        a_ind = a_shuffle(a_cuts(i)+1:a_cuts(i)+fold_size_minority); a_ind_remaining=a_shuffle(a_cuts(i)+fold_size_minority+1:a_cuts(i+1));
        b_ind = b_shuffle(b_cuts(i)+1:b_cuts(i+1));
        a_values = a(a_ind); a_values_remaining = a(a_ind_remaining);
        b_values = b(b_ind);
        a_tmp{i}=a_values;
        b_tmp{i}=b_values;
        a_tmp_remaining{i}=a_values_remaining;
    else
        a_ind = a_shuffle(a_cuts(i)+1:a_cuts(i+1));
        b_ind = b_shuffle(b_cuts(i)+1:b_cuts(i)+fold_size_minority);b_ind_remaining=b_shuffle(b_cuts(i)+fold_size_minority+1:b_cuts(i+1));
        a_values = a(a_ind);
        b_values = b(b_ind);b_values_remaining = b(b_ind_remaining);
        a_tmp{i}=a_values;
        b_tmp{i}=b_values;
        b_tmp_remaining{i}=b_values_remaining;
    end
end

tmp_remaining=[];
if ~isempty(a_tmp_remaining{1})
    for k=1:length(a_tmp_remaining)
        tmp_remaining=[tmp_remaining; a_tmp_remaining{k}];
    end
else
    for k=1:length(b_tmp_remaining)
        tmp_remaining=[tmp_remaining; b_tmp_remaining{k}];
    end
end

for i=1:n
    %     if length(a)>=length(b)
    tmp_a=[];
    for k=1:length(a_tmp)
        if k~=i
            tmp_a=[tmp_a; a_tmp{k}];
        end
    end
    
    tmp_b=[];
    for k=1:length(b_tmp)
         if k~=i
             tmp_b=[tmp_b; b_tmp{k}];
         end
    end
    training{i}= [tmp_a(:) ; tmp_b(:)];
    testing{i} = [a_tmp{i}; b_tmp{i}; tmp_remaining];
end



% sum(data_labels(training{i})) sum(~data_labels(training{i}))