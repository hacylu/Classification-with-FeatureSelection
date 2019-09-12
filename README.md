# Classification_with_FeatureSelection
Routine tools for classification and feature selection using Matlab.
This set of code scripts are based on the CCIPD classification toolbox.
Please check example.m and test_classfification_function_with_knowdataset.m to konw how to run it (The organization of the code is not good since I don't have too much time to clean it).

# What this code can do
This code can help you to do cross validation/leaveone out by considering different simple classifiers with different feature selection methods. The code can help you to keep track which features have been pick up the most frequently.
It can also handle skewed class samples between positve and negative class (trun para.balanced_trainset=1, it will use Multiple-Expert-System to build the classifier).
