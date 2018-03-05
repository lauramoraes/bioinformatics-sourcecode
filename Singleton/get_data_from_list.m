function [X, X_unbalanced, original_class, original_index, used_index, balanced_class] = get_data_from_list(separated_list, data, balance, save, dimensions_label, disorders_labels)
%% Get actual data from separated_list index and map it to different classes
% Parameters:
% separated_list: index list from each class
% data: actual data points
% balance_data: boolean value to indicate whether the script should balance
% the data or not. Default: false
% save: in which directory the plot should be saved. If none, no plot is
% made.
% dimensions_label: plot parameters. Axis label to appear in the plot.
% disorders_labels: plot parameters. Data label to appear in the plot.

X = [];
Y = [];
original_class = [];

%Get data points
for j=1:length(separated_list)
    X{j} = [];
    original_class{j} = [];
    original_index{j} = [];
    % Add it to X
    for i=1:length(separated_list{j})
        X{j} = [X{j}; data{separated_list{j}(i)}];
        original_class{j} = vertcat(original_class{j}, ones(size(data{separated_list{j}(i)},1),1)*separated_list{j}(i));
        original_index{j} = vertcat(original_index{j}, [ones(size(data{separated_list{j}(i)},1),1)*separated_list{j}(i) (1:size(data{separated_list{j}(i)},1))']);
    end
end

X_unbalanced = X;

% Balance data
if exist('balance', 'var') && (balance == true)
%     [X, used_index, balanced_class] = balance_data(X);
%     % If there was any balancing, update original class
%     if balanced_class
%         original_balanced_class = original_class{balanced_class}(used_index);
%         original_class{balanced_class} = original_balanced_class;
%     end

%    epc = {};

    for j=1:length(separated_list)
        % Check if class is unbalanced inside
        if length(unique(original_class{j})) > 1
            [elements_per_class, class_order] = hist(original_class{j}, unique(original_class{j}));
        else
            [elements_per_class, class_order] = hist(original_class{j}, 1);
        end
%         epc{j} = elements_per_class;
        if length(unique(elements_per_class)) > 1
            max_elems = max(elements_per_class);
            for i=1:length(elements_per_class)
                if ~(elements_per_class(i) == max_elems)
                    position = find(separated_list{j} == class_order(i));
                    data_per_class = data{separated_list{j}(position)};
                    % Create random index list to replicate elements
                    index = randi(elements_per_class(i),(max_elems-elements_per_class(i)),1);
                    used_index = [[1:elements_per_class(i)]'; index];
                    for index_element=1:length(index)
                        X{j} = [X{j}; data_per_class(index(index_element),:)];
                        original_class{j} = vertcat(original_class{j}, separated_list{j}(position));
                        original_index{j} = vertcat(original_index{j}, [separated_list{j}(position) index(index_element)]);
                    end
                end
            end
        end
    end
%     disp('BALANCEANDO');
%     fprintf('Classe 1: %s\n', mat2str(separated_list{1}));
%     fprintf('Elementos: %s\n', mat2str(epc{1}));
%     fprintf('Classe 2: %s\n', mat2str(separated_list{2}));
%     fprintf('Elementos: %s\n', mat2str(epc{2}));
%     
%     disp('DEPOIS')
%     if length(unique(original_class{1})) > 1
%         [epc{1}, position] = hist(original_class{1}, unique(original_class{1}));
%     else
%         [epc{1}, position] = hist(original_class{1}, 1);
%     end
%     fprintf('Classe 1: %s\n', mat2str(separated_list{1}));
%     fprintf('Elementos: %s\n', mat2str(epc{1}));
%     fprintf('Classe 2: %s\n', mat2str(separated_list{2}));
%     if length(unique(original_class{2})) > 1
%         epc{2} = hist(original_class{2}, unique(original_class{2}));
%     else
%         epc{2} = hist(original_class{2}, 1);
%     end
%     fprintf('Elementos: %s\n', mat2str(epc{2}));
%     disp('breakpoint')
end


% Plot data
if exist('save', 'var')
    space_plot = plot_space(X, length(separated_list), [1, 2], 2, dimensions_label);
    legend(disorders_labels);
    saveas(space_plot, save, 'fig');
    saveas(space_plot, save, 'png');
end
