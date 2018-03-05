function [weight, weight1] = linear_regression_modified_pinv(X, Y)
%% Function to calculate the weight vector that represents the hyperplane
%% to separate two classes using linear regression

N{1} = size(X{1}, 1);
N{2} = size(X{2}, 1);

%weight = (((X{1}'*X{1})./N{1})+((X{2}'*X{2})./N{2}))\(((X{1}'*Y{1})./N{1})+((X{2}'*Y{2})./N{2}));
denominator = ((X{1}'*X{1})./N{1})+((X{2}'*X{2})./N{2});
numerator = ((X{1}'*Y{1})./N{1})+((X{2}'*Y{2})./N{2});
if isnan(numerator) || isnan(denominator)
    weight = (((X{1}'*X{1})./N{1})+((X{2}'*X{2})./N{2}))\(((X{1}'*Y{1})./N{1})+((X{2}'*Y{2})./N{2}));
else
    denom_inv = pinv(denominator);    
    weight = denom_inv * numerator;
end

% Compare with normal linear regression
X_total = vertcat(X{1}, X{2});
Y_total = vertcat(Y{1}, Y{2});

weight1 = pinv(X_total)*Y_total;