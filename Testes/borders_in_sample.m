function borders_in_sample(original_dataset_path, marc, marc_label, borders_matrix_path)
%% Using Lasso to determine borders

%original_dataset_path = 'Dataset/seb_cell_2015_07_23_norm_lpl+mzl.mat';
%original_dataset_path = 'Dataset/cal_housing.mat';
%original_dataset_path = 'Dataset/digits.mat';
%original_dataset_path = 'Dataset/yaleb.mat';
%original_dataset_path = 'Dataset/mnist.mat';
%original_dataset_path = 'Dataset/usps.mat';
borders_matrix_temp = [];
borders_matrix = [];
node = struct('parent', 0, 'key', [], 'lchild', -1, 'rchild',-1, 'confusion_matrix', [], 'save_folder', '', 'dataset_path', '', ...
              'accuracy', 0, 'llist',  [], 'rlist', [], 'listA', [], 'listB', [], 'elements', [], 'weight', [], 'model', [], ...
              'single_elements', [], 'under_cut', 0, 'mu', [], 'sigma', [], 'upper_limit', 0.5, 'lower_limit', 0.5);
borders_matrix_temp = [borders_matrix_temp; node];
borders_matrix = [borders_matrix; node];

% Load data
fname=fullfile(original_dataset_path);
load(fname);

train_set = extract_features(marc, train_set);
obs_set = 1:size(train_set,2);

combinations = combnk(obs_set, 2);
%combinations = repmat(combinations_temp, 3, 1);

x = combinations(:,1);
y = combinations(:,2);

tic;
parfor i=1:length(combinations)
%for i=1:length(combinations)
 %for i=1:size(combinations, 1)
    %     separated_list{1} = x(i);
    %     separated_list{2} = y(i);
    %     sufix = sprintf('%d_%d_%d', x(i), y(i), fix((i-1)/(length(combinations_temp))))
    %     disp('Working on:')
    %     disp(sufix)
    
    [X, original_class] = get_data_from_list({x(i) y(i)},train_set, false);
    [X,Y, mu, sigma] = load_data(X, false, false, false);
    %% Não entendi porque troquei antes e agora destroquei \_(?)_/
    %Y(find(Y==1)) = 0;
    %Y(find(Y==-1)) = 1;
    Y(find(Y==-1)) = 0;
    %     X_original = X;
    %     Y_original = Y
    
    
    %     total_set = size(Y_original, 1)
    %     Y_out_final = zeros(total_set, 1);
    %     Y_out_final = ones(total_set, 1);
    %     for j=1:total_set
    %         X = X_original;
    %         Y = Y_original;
    %         element = X(j,:);
    %         X(j,:) = [];
    %         Y(j,:) = [];
    %
    %         sufix = sprintf('%d_%d_%d', x(i), y(i), j)
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
    %[w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'Weights', balanced_weights, 'CV', 30);
    fit = glmnet(X, Y, 'binomial', opts);
%         [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 10);
    %         [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'CV', 20);
    %E_in_hist = FitInfo.Deviance;
    E_in_hist = fit.dev;
    
    % Weight for min error found
    %[err, index] = min(E_in_hist);
    [err, index] = max(E_in_hist);
    
    %weight = vertcat(FitInfo.Intercept(index), w(:, index));
    weight = vertcat(fit.a0(index), fit.beta(:, index));
    %     disp('Pesos calculados pela regularização:');
    %     disp(weight);
    
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
    
    [pathstr,name,ext] = fileparts(borders_matrix_path);
    fig_name_roc = sprintf(strcat(pathstr, '/roc_%s'), sufix);
    fig_name1 = sprintf(strcat(pathstr, '/logist_%s'), sufix);
    fig_name2 = sprintf(strcat(pathstr, '/confusion_mat_%s'), sufix);
    saveas(h_roc, fig_name_roc,'fig');
    saveas(h_roc, fig_name_roc,'png');
    saveas(h1, fig_name1,'fig');
    saveas(h1, fig_name1,'png');
    saveas(h2, fig_name2,'fig');
    saveas(h2, fig_name2,'png');
    
    
    h3 = figure;
    %     h3 = barh(flipud(markers_plot(1:5)));
    markers_plot_percent = 100*markers_plot/sum(markers_plot(:));
    h3 = barh(flipud(markers_plot_percent));
    %     set(gca,'ytickLabel',markers_names(flipud(index_sort(1:5))))
    set(gca,'ytickLabel',markers_names(flipud(index_sort)));
    
    fig_name3 = sprintf(strcat(pathstr, '/markers_%s'), sufix);
    saveas(h3, fig_name3,'fig');
    saveas(h3, fig_name3,'png');
    %     fprintf('Classify element 2\n')
    %     fprintf('-1 == 3\n')
    %     fprintf('1 == 5\n')
    %         [y_out, y_hat] = classify_data([1 element], weight);
    %         Y_out_final(j) = y_out;
    close all
    
    confusion_matrix = confusionmat(Y, y_out);
    accuracy = (confusion_matrix(1,1)+confusion_matrix(2,2))/sum(confusion_matrix(:))*100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     end
%         Y = Y_original;
%         target = [Y ~Y]';
%         Y_out_final(find(Y_out_final==-1)) = 0;
%         output = [Y_out_final ~Y_out_final]';
%         h2 = figure('Visible', 'off');
%         plotconfusion(target, output);
%         set(gcf, 'Visible', 'off')
%         %     categories = cell2mat(separated_list);
%         categories = cell2mat({x(i) y(i)});
%         set(gca,'xticklabel',categories);
%         set(gca,'yticklabel',categories);
%         fig_name2 = sprintf('Resultados/confusion_mat_%d_%d', x(i), y(i));
%         saveas(h2, fig_name2,'fig');
%         saveas(h2, fig_name2,'png');
    % Append to a model matrix
%     size(weight)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    node = struct('parent', 0, 'key', [x(i); y(i)], 'lchild', -1, 'rchild',-1, 'confusion_matrix', confusion_matrix, 'save_folder', '', 'dataset_path', '', ...
                  'accuracy', accuracy, 'llist',  x(i)*ones(size(train_set{x(i)},1), 1), 'rlist', y(i)*ones(size(train_set{y(i)},1), 1),'listA', x(i), 'listB', y(i), ...
                  'elements', [size(train_set{x(i)}, 1) size(train_set{y(i)}, 1)], 'weight', markers_plot_percent, 'model', weight, ...
                  'single_elements', [], 'under_cut', 1, 'mu', [], 'sigma', [], 'upper_limit', upper_limit, 'lower_limit', lower_limit);
    borders_matrix_temp(i,:) = node;
end
t = toc;
disp('Elapsed Time: ')
disp(t);

for i=1:length(combinations)
    borders_matrix(x(i), y(i)) = borders_matrix_temp(i,:);
    borders_matrix(y(i), x(i)) = borders_matrix_temp(i,:);
end
%save('Datasets/Dataset/borders_matrix.mat', 'borders_matrix');
save(borders_matrix_path, 'borders_matrix');