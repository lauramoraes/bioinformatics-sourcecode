function svm_struct = svm(X, Y, kernel_function)
%% Function to calculate the weight vector that represents the hyperplane
%% to separate two classes using logistic regression

svm_struct = svmtrain(X,Y,'autoscale', true, 'kernel_function', kernel_function, 'method', 'SMO');