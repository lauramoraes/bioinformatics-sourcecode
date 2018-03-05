function borders_youden_max_dor(original_dataset_path, marc, marc_label)
%% Experimental script to calculate Youden and MaxDor cutpoints

% Load data
fname=fullfile(original_dataset_path);
load(fname);

train_set = extract_features(marc, train_set);
obs_set = 1:size(train_set,2);

combinations = combnk(obs_set, 2);
%combinations = repmat(combinations_temp, 3, 1);

x = combinations(:,1);
y = combinations(:,2);

for i=1:length(combinations)
    
    [X, original_class] = get_data_from_list({x(i) y(i)},train_set, false);
    [X,Y, mu, sigma] = load_data(X, false, false, false);
    %% Não entendi porque troquei antes e agora destroquei \_(?)_/
    %Y(find(Y==1)) = 0;
    %Y(find(Y==-1)) = 1;
    Y(find(Y==-1)) = 0;
    sufix = sprintf('%d_%d', x(i), y(i));
    disp('Working on:')
    disp(sufix)
    
    balanced_weights = [];
    obs_total = find(Y == 0);
    balanced_weights(obs_total) = 1/length(obs_total);
    obs_total = find(Y == 1);
    balanced_weights(obs_total) = 1/length(obs_total);
    %
    opts=struct('standardize',false, 'weights', balanced_weights');
    opts.nfolds = 30;
    opts.parallel = true;
    fit = glmnet(X, Y, 'binomial', opts);
    E_in_hist = fit.dev;
    
    % Weight for min error found
    [err, index] = max(E_in_hist);
    
    weight = vertcat(fit.a0(index), fit.beta(:, index));
    
    % Classify insample data
    Y_out = mnrval(weight,X);
    [y_out, y_hat] = classify_data([ones(size(X,1),1) X] ,weight);
    y_out(find(y_out==-1)) = 0;
    
    % Get most used markers
    used_markers = weight(2:end);
    to_remove = find(used_markers == 0);
    used_markers(to_remove) = [];
    markers_names = marc_label;
    markers_names(to_remove) = [];
    [markers_plot, index_sort] = sort(abs(used_markers), 'descend');
    
    %% Borders using MaxSe and MaxSp
%     upper_limit_0 = max(y_hat(Y == 0));
%     upper_limit_1 = min(y_hat(Y == 1 & y_hat > upper_limit_0));
%     upper_limit = mean([upper_limit_0 upper_limit_1]);
%     lower_limit_1 = min(y_hat(Y == 1));
%     lower_limit_0 = max(y_hat(Y == 0 & y_hat < lower_limit_1));
%     lower_limit = mean([lower_limit_0 lower_limit_1]);
    
    %% Borders using Youden and MaxDor
    h_roc = figure('Visible', 'on');
    [fpr,tpr,T] = perfcurve(Y, y_hat, 1);
    % Youden
    [value_youden, idx_youden] = max(tpr-fpr);
    youden_thr = T(idx_youden);
    
    % MaxDor
    fpr_dor = fpr + 0.01;
    tpr_dor = tpr + 0.01;
    [value_maxdor, idx_maxdor] = max(log(tpr_dor) - log(1-tpr_dor) - (log(fpr_dor) - log(1-fpr_dor)));
    maxdor_thr = T(idx_maxdor);
    
    plot(fpr,tpr);
    hold on;
    scatter(fpr(idx_youden), tpr(idx_youden));
    scatter(fpr(idx_maxdor), tpr(idx_maxdor));
    legend('ROC', 'Youden', 'MaxDor2');
    
    h1 = figure('Visible', 'on');
    scatter(X(:,index_sort(1)),y_hat(:,1), 80, Y, 'LineWidth',2);
    hold on
    upper_limit = max(youden_thr, maxdor_thr);
    lower_limit = min(youden_thr, maxdor_thr);
    
    line([min(X(:,index_sort(1))) max(X(:,index_sort(1)))], [0.5 0.5])
    line([min(X(:,index_sort(1))) max(X(:,index_sort(1)))], [upper_limit upper_limit], 'LineStyle', '--', 'Color', 'red')
    line([min(X(:,index_sort(1))) max(X(:,index_sort(1)))], [lower_limit lower_limit], 'LineStyle', '--', 'Color', 'red')
    hold off
    
    target = [Y ~Y]';
    output = [y_out ~y_out]';
    h2 = figure('Visible', 'off');
    plotconfusion(target, output);
    set(gcf, 'Visible', 'off')
    %     categories = cell2mat(separated_list);
    categories = cell2mat({x(i) y(i)});
    set(gca,'xticklabel',categories);
    set(gca,'yticklabel',categories);
end

