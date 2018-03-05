function [weight, E_in_hist, lambda, h_hist, w] = lasso_regression_tibishirani(X, Y, CV)

if ~exist('CV', 'var')
    CV = false;
end

% Changing -1 to 0
Y(find(Y==-1)) = 0;

balanced_weights = [];
obs_total = find(Y == 0);
balanced_weights(obs_total) = 1/length(obs_total);
obs_total = find(Y == 1);
balanced_weights(obs_total) = 1/length(obs_total);

opts=struct('standardize',false, 'weights', balanced_weights', 'thresh', 1e-03);

if CV
    if size(X, 1) < 20
        CV = size(X, 1);
    else
        CV = 20;
    end
    opts.nfolds = 20;
    opts.parallel = true;
    fit = glmnet(X, Y, 'binomial', opts);
    % Get parameters
    E_in_hist = fit.cvm;
    h_hist = fit.lambda;
    % Weight for min error found
    [err, index] = min(E_in_hist);
    lambda = h_hist(index);
    weight = cvglmnetCoef(fit, h_hist(index));
    w = weight(2:end);
else
    fit = glmnet(X, Y, 'binomial', opts);
    % Get parameters
    E_in_hist = fit.dev;
    h_hist = fit.lambda;
    % Weight for min error found
    [err, index] = max(E_in_hist);
    lambda = h_hist(index);
    weight = vertcat(fit.a0(index), fit.beta(:, index));
    w = fit.beta(:, index);
end
