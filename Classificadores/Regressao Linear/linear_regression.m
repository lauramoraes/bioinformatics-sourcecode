function weight = linear_regression(X, Y)
%% Function to calculate the weight vector that represents the hyperplane
%% to separate two classes using linear regression

weight = pinv(X)*Y;
%weight = (X'*X)\X' * Y;