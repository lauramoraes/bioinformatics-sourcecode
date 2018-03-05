%% Using Lasso to determine borders

original_dataset_path = 'Dataset/seb_cell_2015_07_23_norm_lpl+mzl.mat';
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

marc = [ 4 5 11 14 16 ];
% marc = 1:24;
train_set = extract_features(marc, train_set);

patient_set = 1:8;

combinations = combnk(patient_set, 2);
%combinations = repmat(combinations_temp, 3, 1);

x = combinations(:,1);
y = combinations(:,2);

for j=1:size(train_set,2)
    for k=1:size(train_set{j})
        
        % Load data
        fname=fullfile(original_dataset_path);
        load(fname);
        
        train_set{j}(k, :) = [];
        fmt = sprintf('%d_%d', j, k);
        if ~exist(strcat('Resultados/', fmt), 'dir')
            mkdir(strcat('Resultados/', fmt))
        end
        if ~exist(strcat('Datasets/', fmt), 'dir')
            mkdir(strcat('Datasets/', fmt))
        end
        parfor i=1:length(combinations)
            [X, original_class] = get_data_from_list({x(i) y(i)},train_set, false);
            [X,Y, mu, sigma] = load_data(X, false, false, false);
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
            [w, FitInfo] = lassoglm(X, Y, 'binomial', 'Standardize', false, 'NumLambda', 50, 'Weights', balanced_weights, 'CV', 30);
            E_in_hist = FitInfo.Deviance;
            
            % Weight for min error found
            [err, index] = min(E_in_hist);
            
            weight = vertcat(FitInfo.Intercept(index), w(:, index));
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
            
            h1 = figure('Visible', 'off');
            scatter(X(:,index_sort(1)),y_hat(:,1), 80, Y, 'LineWidth',2);
            hold on
            upper_limit_0 = max(y_hat(Y == 0));
            upper_limit_1 = min(y_hat(Y == 1 & y_hat > upper_limit_0));
            upper_limit = mean([upper_limit_0 upper_limit_1]);
            lower_limit_1 = min(y_hat(Y == 1));
            lower_limit_0 = max(y_hat(Y == 0 & y_hat < lower_limit_1));
            lower_limit = mean([lower_limit_0 lower_limit_1]);
            
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
            
            fig_name1 = sprintf(strcat('Resultados/', fmt, '/logist_%s'), sufix);
            fig_name2 = sprintf(strcat('Resultados/', fmt, '/confusion_mat_%s'), sufix);
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
            
            fig_name3 = sprintf(strcat('Resultados/', fmt, '/markers_%s'), sufix);
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
        end;
        for i=1:length(combinations)
            borders_matrix(x(i), y(i)) = borders_matrix_temp(i,:);
            borders_matrix(y(i), x(i)) = borders_matrix_temp(i,:);
        end
        save(strcat('Datasets/', fmt, '/borders_matrix.mat'), 'borders_matrix');
    end;
end