function [weight, E_in_hist, lambda, h_hist, w] = lasso_regression(X, Y, CV)

if ~exist('CV', 'var')
    CV = false;
end

% Changing -1 to 0
Y(find(Y==-1)) = 0;

%[w, FitInfo] = lassoglm(X, Y, 'CV', size(X,1))
%[w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'Lambda', [0.000001 0.00001 0.0001]);
balanced_weights = [];
obs_total = find(Y == 0);
balanced_weights(obs_total) = 1/length(obs_total);
obs_total = find(Y == 1);
balanced_weights(obs_total) = 1/length(obs_total);

if CV
    if size(X, 1) < 20
        CV = size(X, 1);
    else
        CV = 20;
    end
    [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'Weights', balanced_weights, 'CV', CV);
else
    [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'Weights', balanced_weights);
end

% [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50);
% [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'Lambda', [0.000001 0.00001 0.0001], 'CV', 10);
%[w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'CV', 10);

% Get parameters
E_in_hist = FitInfo.Deviance;
h_hist = FitInfo.Lambda;

% Weight for min error found
[err, index] = min(E_in_hist);
lambda = h_hist(index);

weight = vertcat(FitInfo.Intercept(index), w(:, index));
