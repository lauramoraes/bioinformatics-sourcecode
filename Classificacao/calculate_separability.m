function separability = calculate_separability(yhat, y, mode, sep_value)
%% Calculate distance to separation value in a logistic function
%% Parameters:
% yhat: yhat values for each observation
% y: expected classes (present if you need a balanced calculation among
% classes. If absent, distance will be calculated ignoring the quantity of
% observations in each class.
% mode: average or mininum distance. Default: average
% sep_value: value where the separability is measured from. Default: 0.5

if ~exist('mode', 'var')
    mode = 'average';
end

if ~exist('sep_value', 'var')
    sep_value = 0.5;
end

n = {};
if ~exist('y', 'var')
    n{1} = size(yhat, 1);
    n{2} = size(yhat, 1);
else
    classes = unique(y);
    if size(classes,1) ~= 2
        fprintf('More than 2 classes found! This function is not defined to handle more than two classes');
        separability = 0;
        return;
    else
        ix{1} = find(y == classes(1));
        n{1} = size(ix{1}, 1);
        ix{2} = find(y == classes(2));
        n{2} = size(ix{2}, 1);
    end
end

if strcmp(mode, 'average')
    separability = abs(sum(yhat(ix{1},:)-sep_value)/n{1}) + abs(sum(yhat(ix{2},:)-sep_value)/n{2});
elseif strcmp('mode', 'min')
    disp('Minimum mode not developed yet.')
    separability = 0;
    return;
end