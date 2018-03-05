function [X, Y, mu, sigma] = load_data(separated_data, leave_separated, bias, apply_zscore)
%% Function to load data from cells to matrix X and target matrix Y to
%% perform linear/logistic regression classification
% Parameters:
% separated_data = data in cells. Each cell index represents a different
% class
% leave_separated: join all data in a single variable or keep it separated
% in indexes. Default: false
% bias: whether or not to add bias as first column. Default: true
% apply_zscore: whether or not to apply zscore normalization. Default: true

% If bias = false and zscore = false, just use data
mu = 0;
sigma = 0;
x1= [separated_data{1}];
x2= [separated_data{2}];

if ((~exist('apply_zscore')) || (exist('apply_zscore','var') && (apply_zscore == true)))
    %[X_total, mu, sigma] = zscore(vertcat(x1, x2));
    X_temp = vertcat(x1, x2);
    max_val = max(X_temp);
    max_vals = repmat(max_val,size(X_temp,1),1);
    min_val = min(X_temp);
    min_vals = repmat(min_val,size(X_temp,1),1);
    X_total = 10*(X_temp - min_vals)./(max_vals-min_vals);
    mu = max_vals;
    sigma = min_vals;
else
    X_total = vertcat(x1, x2);
end

if ((~exist('bias')) || (exist('bias','var') && (bias == true)))
    % Otherwise, first columnn = 1 
    X_total = [ones(size(X_total,1),1) X_total];
end

if (exist('leave_separated', 'var') && (leave_separated == true))
    X{1}= X_total(1:size(separated_data{1},1),:);
    X{2}= X_total(size(separated_data{1},1)+1:end,:);

    Y{1} = -1.*ones(size(separated_data{1}, 1), 1);
    Y{2} = ones(size(separated_data{2}, 1), 1);
else
    X = X_total;
    Y = [-1.*ones(size(separated_data{1}, 1), 1); ones(size(separated_data{2}, 1), 1)]; 
end
