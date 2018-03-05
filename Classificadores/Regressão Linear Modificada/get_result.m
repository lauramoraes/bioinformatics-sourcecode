function y_out = get_result(X, w)
%% Function to classify based on the previous inputs and weight vector
% Parameters:
% X: data used to train the linear model
% w: weight vector extracted from the linear regression

y_out = X*w;