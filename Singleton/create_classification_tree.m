function [tree_index, classification_tree, remaining, removed, conf_remaining, found_singleton] = create_classification_tree(dataset_path, first_list_path, borders_path, save_folder_base, available_classes, total, stop, marc, min_w, verbose, classification_tree, parent, single_elements, remaining, conf_remaining, removed, found_singleton, leaf)

%Load data
fname=fullfile(dataset_path);
load(fname);
%Load data
fname=fullfile(first_list_path);
load(fname);

% Default value
percent_per_class = zeros(1, size(total,2));
if ~exist('stop','var')
    stop = 0;
end
if ~exist('min_w','var')
    min_w = false;
end
if ~exist('verbose','var')
    verbose = true;
end

if ~exist('leaf','var')
    leaf = false;
end

%%%%%%%%%%%%%%%
%% ALG3-ROOT %%
%%%%%%%%%%%%%%%
% For first initialization
if ~exist('classification_tree','var')
    classification_tree = [];
    parent = 0;
    % Init remaining elements cell array
    remaining = cell(1, size(train_set,2));
    for i=1:size(remaining,2)
        remaining{i} = [];
        removed{i} = [];
    end
    conf_remaining = [];
    found_singleton = false;
end

tree_index = (size(classification_tree,1))+1;
save_folder = strcat(save_folder_base, '/', int2str(tree_index));
node = struct('parent', parent, 'key', unique(available_classes), 'lchild', -1, 'rchild',-1, 'confusion_matrix', [], 'save_folder', save_folder, 'dataset_path', dataset_path, ...
              'accuracy', 0, 'llist',  [], 'rlist', [], 'listA', [], 'listB', [], 'elements', [], 'weight', [], 'model', [], ...
              'single_elements', [], 'under_cut', 1, 'mu', [], 'sigma', [], 'upper_limit', 0.5, 'lower_limit', 0.5);
classification_tree = [classification_tree; node];

% Available elements per class
node.elements = hist(available_classes, unique(available_classes));
node.elements = node.elements(node.elements~=0);

%%%%%%%%%%%%%%%
%% ALG3-PMIN %%
%%%%%%%%%%%%%%%
% If stop condition
if stop ~= 0
    found = false;
    classes = unique(available_classes);
    percent_per_class = zeros(1, size(total,2));
    if ~isempty(node.elements)
        for i=1:size(node.elements,2)
            percent_per_class(classes(i)) = node.elements(i)/total(classes(i));
            if percent_per_class(classes(i)) >= stop
                found = true;
            end
        end
    end
    %%%%%%%%%%%%%%%%%
    %% ALG3-REMOVE %%
    %%%%%%%%%%%%%%%%%
    if found == false
        % No remaining classes arrive to the limit
        % Get remaining elements
        %remaining = train_set;
        removed = train_set;
        % Delete node from tree
        classification_tree(tree_index) = [];
        tree_index = -1;
        return
    end
end
%%%%%%%%%%%%%%%%%%%%
%% ALG3-SINGLETON %%
%%%%%%%%%%%%%%%%%%%%
% Find singleton
if length(node.key) == 1
    if exist('single_elements', 'var') && ~isempty(single_elements)
        node.single_elements = single_elements;
    end
    node.elements = hist(available_classes, length(node.key));
    classification_tree(tree_index) = node;
    found_singleton = true;
    
    % Get keys from previous division
    keys = classification_tree(node.parent).key;
    parent = tree_index;
    key_parent = node.key;
    % If it was separated from more than one class, we try it against each
    % class singularly
    % Remove key from array
%     keys(keys == node.key) = [];
    if ((length(keys) >= 2) && (leaf == false))
        keys = classification_tree(1).key;
        keys(keys == node.key) = [];
        leaf = true;
        for i=1:length(keys)
            fprintf('Generate classification for classes %d and %d\n', key_parent, keys(i))
            tree_index = (size(classification_tree,1))+1;
            save_folder = strcat(save_folder_base, '/', int2str(tree_index));
            node_temp = struct('parent', parent, 'key', unique(available_classes), 'lchild', -1, 'rchild',-1, 'confusion_matrix', [], 'save_folder', save_folder, 'dataset_path', dataset_path, ...
                               'accuracy', 100, 'llist',[], 'rlist',[],'listA', [], 'listB',[], 'elements',0, 'weight', [], 'model', [], 'single_elements', [], 'under_cut', 1, 'mu', [], 'sigma', []);
            
            %Load data
            fname=fullfile(borders_path);
            load(fname);
            
            node = borders_matrix(key_parent, keys(i));
            node.parent = node_temp.parent;
            node.save_folder = node_temp.save_folder;
            node.dataset_path = node_temp.dataset_path;
            
            % Update tree
            classification_tree(tree_index) = node;
        end
    tree_index = parent;
    end
    return
end

if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

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

% size(first_list)
first_list = remove_permutation(first_list, available_classes);
% size(first_list)
% pause
first_list_path = strcat(save_folder, '/first_list.mat');
save(first_list_path, 'first_list');

% Save train_set with just specified markers
train_set_init = train_set;
train_set = extract_features(marc, train_set);
[pathstr,name,ext] = fileparts(dataset_path);
dataset_path_marc = strcat(pathstr, '/', name, '_marc', ext);
save(dataset_path_marc, 'train_set');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALG4-REGRESSION e ALG4-SORT %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tic;
%[first_list, all_lists] = get_accuracy_csv(dataset_path_marc, first_list_path, save_folder, 'logistic_regression', false, percent_per_class, min_w);
[first_list, all_lists] = get_accuracy_csv(dataset_path_marc, first_list_path, save_folder, 'lasso_regression', true, percent_per_class, min_w);
%t1 = toc;
%fprintf('Time for node %d', tree_index)
%disp(t1)
%[first_list, all_lists] = get_accuracy_csv(dataset_path_marc, first_list_path, save_folder, 'linear_regression_modified', false, percent_per_class);
save(first_list_path, 'first_list');

result = [];

 
if (isempty(result))
    %%%%%%%%%%%%%%%%%
    %% ALG3-PRIORT %%
    %%%%%%%%%%%%%%%%%
    best_class = first_list(1,:);
else
    best_class = first_list(result,:);
end

% Create second list after choosing the best combination
separated_list = create_second_list(length(train_set),best_class); 
        
node.listA = intersect(available_classes, separated_list{1});
node.listB = intersect(available_classes, separated_list{2});
if verbose
    disp('First list:')
    disp(node.listA)
    disp('Second list:')
    disp(node.listB)
end
% Separate data
[X_init, X_unbalanced, original_class, original_index] = get_data_from_list(separated_list,train_set, true);

%%%%%%%%%%%%%%%%%%
%% ALG3-CLASSIF %%
%%%%%%%%%%%%%%%%%%
% Train, test and get results
[node, classification,  classification_tree, remaining, removed, conf_remaining, found_singleton] = classify_and_separate_data(best_class, train_set, node, train_set_init, original_class, original_index, X_init, X_unbalanced, total, save_folder, save_folder_base, borders_path, stop, marc, min_w, verbose, classification_tree, tree_index, remaining, conf_remaining, removed, found_singleton, leaf);
end
