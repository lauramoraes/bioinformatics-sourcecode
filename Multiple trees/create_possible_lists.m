function [first_list, all_lists] = create_possible_lists(dataset_path, first_list_path, save_folder, available_classes, marc, total)
%Load data
fname=fullfile(dataset_path);
load(fname);

%Load data
fname=fullfile(first_list_path);
load(fname);

percent_per_class = zeros(1, size(total,2));
classes = unique(available_classes);
node.elements = hist(available_classes, unique(available_classes));
node.elements = node.elements(node.elements~=0);
for i=1:size(node.elements,2)
    percent_per_class(classes(i)) = node.elements(i)/total(classes(i));
end

%disp('Percentage per class')
%disp(percent_per_class)
% pause


%%%%%%%%%%%%%%%%
%% ALG3-COMBN %%
%%%%%%%%%%%%%%%%
% Create all possible classification combinations for this dataset and
% choose the best
% Update first_list to have just the members from class
first_list(find(~ismember(first_list, available_classes))) = 0;
% Remove rows with only zeros
first_list = first_list(any(first_list,2),:);
first_list = sort(first_list, 2, 'descend');
first_list = unique(first_list, 'rows');

% first_list
% size(first_list)

% Remove divisions that are just permutation
% tic;
first_list = remove_permutation(first_list, available_classes);
% t = toc;
% disp('Perm time:')
% disp(t)

% first_list
% size(first_list)
% pause

first_list_path = strcat(save_folder, '/first_list1.mat');
i=1;
while exist(first_list_path, 'file')
    i = i+1;
    first_list_path = strcat(save_folder, '/first_list', int2str(i), '.mat');
end
save(first_list_path, 'first_list');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALG4-REGRESSION e ALG4-SORT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tic;
% [first_list, all_lists] = get_accuracy_csv(dataset_path_marc, first_list_path, save_folder, 'logistic_regression', false, percent_per_class, min_w);
[first_list, all_lists] = get_accuracy_csv(dataset_path, first_list_path, save_folder, 'lasso_regression', false, percent_per_class);
%t1 = toc;
%fprintf('Time for node %d', tree_index)
%disp(t1)
% [first_list, all_lists] = get_accuracy_csv(dataset_path_marc, first_list_path, save_folder, 'linear_regression_modified', false, percent_per_class);
save(first_list_path, 'first_list');
end