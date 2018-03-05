function y_out = get_result(X, svm_struct)
%% Function to classify based on the previous inputs and weight vector
% Parameters:
% X: data used to train the linear model
% svm_struct: SVM trained structure

sv = svm_struct.SupportVectors;
alphaHat = svm_struct.Alpha;
bias = svm_struct.Bias;
kfun = svm_struct.KernelFunction;
kfunargs = svm_struct.KernelFunctionArgs;
y_out = kfun(sv,X,kfunargs{:})'*alphaHat(:) + bias;
