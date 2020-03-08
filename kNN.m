function [methodstring,tp,tn,fp,fn,prediction] = kNN( training_set , testing_set, training_labels, testing_labels, k )

methodstring = 'kNN';

if nargin < 5 || isempty(k)
    k = 1;
end

%W = L2_distance(training_set',testing_set');
%minW = min(W);

%prediction = zeros(size(testing_labels));
%for i=1:size(W,2)
%    temp = training_labels(find(W(:,i)==minW(i)));
%	prediction(i) = temp(1);
%end

prediction = knnclassify(testing_set, training_set, training_labels,k); 

tp = 0; tn = 0; fp = 0; fn  = 0;
for i=1:length(testing_labels)
    if testing_labels(i) == 1
        if prediction(i) == testing_labels(i)
            tp = tp+1;
        else
	    fp = fp+1;
        end
    else
        if prediction(i) == testing_labels(i)
            tn = tn+1;
        else
            fn = fn+1;
        end
    end
end
