function [y_out, y_hat] = classify_data(X, trained_model, method)
%% Function to classify based on the previous inputs and trained_model
% Parameters:
% X: data used to train the model
% trained_model: trained model. Weight vector extracted from the linear 
% regression or SVM trained structure.
% method: classification method. Linear or logistic regression, linear or
% quadratic SVM
% SVM. Default: logistic regression.

if ((exist('method', 'var') && strncmp(method, 'svm', 3)))
    y_out = svmclassify(trained_model,X);
    y_hat = ''
elseif ((exist('method', 'var') && strncmp(method, 'linear', 6)))
    y_hat = X*trained_model;
    y_out = sign(y_hat);
else
    y_hat = X*trained_model;
    exp_val = exp(y_hat);
    exp_val(find(isinf(exp_val) == 1)) = realmax;
    y_hat = (exp_val ./ (1 + exp_val));
    y_out = sign(y_hat-0.5+eps);
end