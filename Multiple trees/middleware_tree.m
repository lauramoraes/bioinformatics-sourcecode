function tree_path = middleware_tree(dataset_path, first_list_path, tree_result, available_classes_base, marc, total, classification_tree_folder, level)
%Load data
fname=fullfile(dataset_path);
load(fname);

% % Save train_set with just specified markers
train_set = extract_features(marc, train_set);
[pathstr,name,ext] = fileparts(dataset_path);
dataset_path_marc = strcat(pathstr, '/', name, '_marc', ext);
if (exist('available_classes', 'var'))
    save(dataset_path_marc, 'train_set', 'available_classes', 'parent');
else
    save(dataset_path_marc, 'train_set', 'marc_label');
end

if (~exist('classification_tree_folder', 'var')) || (isempty(classification_tree_folder))
    classification_tree_base = [];
    parent_base = 0;
else
    %Load data
    fname=fullfile(classification_tree_folder);
    load(fname);
    classification_tree_base = classification_tree;
    parent_base = parent;
end

% Get all possible partitions
available_classes = available_classes_base;
[first_list, all_lists] = create_possible_lists(dataset_path_marc, first_list_path, tree_result, available_classes, marc, total);

% size(first_list)
% pause

% To do by parts
% if exist('level','var') && level == 1
%     first_list = first_list(5,:)
%     pause
% end

%Shuffle partition order
n = size(first_list, 1);
% ix = randperm(n);
% first_list = first_list(ix,:);

% Limit number of used partitions
% if n > 10
%      n = 10;
% end

tree_path = {};

for item=1:n
    classification_tree = classification_tree_base;
    parent = parent_base;
    available_classes = available_classes_base;
    
    % Get next available folder
    all_folders = dir(tree_result);
    next_folder = size(all_folders([all_folders.isdir]),1)-1;
    tree_folder = strcat(tree_result, '/', int2str(next_folder));
%     disp('middleware')
%     pause
    
    if ~rem(next_folder,5)
        fprintf('Creating tree %d\n', next_folder)
    end
    
    % Control when tree changes partitions
    if item == 1
        if ~exist(strcat(tree_result,'/tree_control.mat'), 'file')
            tree_control = {};
        else
            load(strcat(tree_result,'/tree_control.mat'));
        end
        tree_control = [tree_control; tree_folder];
        save(strcat(tree_result,'/tree_control.mat'), 'tree_control');
    end
    
    % Create node and add it to tree
    [train_set_ldata, train_set_rdata, node, found_singleton] = create_node_model(dataset_path_marc, parent, available_classes, first_list(item,:), total);
    classification_tree = [classification_tree; node];
    assignin('base','classification_tree', classification_tree);
    
    if ~exist(tree_folder, 'dir')
        mkdir(tree_folder);
    end
      
    if found_singleton == true
        tree_path = strcat(tree_folder, '/tree.mat');
        save(tree_path, 'classification_tree');
        continue;
    end
    
    parent = length(classification_tree);
    
    train_set = train_set_ldata';
    available_classes = node.llist;
    save(strcat(tree_folder, '/ldata.mat'), 'train_set', 'available_classes', 'parent');
    %[node.lchild, classification_tree, lremaining, lremoved, conf_remaining, found_singleton] = create_classification_tree(strcat(tree_folder, '/ldata.mat'), first_list_path, tree_folder, node.llist, total, 0, marc, 0, true, classification_tree, parent, [], [], [], [], found_singleton);
    
    train_set = train_set_rdata';
    available_classes = node.rlist;
    save(strcat(tree_folder, '/rdata.mat'), 'train_set', 'available_classes', 'parent');
    %[node.rchild, classification_tree, lremaining, lremoved, conf_remaining, found_singleton] = create_classification_tree(strcat(tree_folder, '/rdata.mat'), first_list_path, tree_folder, node.rlist, total, 0, marc, 0, true, classification_tree, parent, [], [], [], [], found_singleton);

    classification_tree(length(classification_tree));
    tree_path = [tree_path; strcat(tree_folder, '/tree.mat')];
    save(strcat(tree_folder, '/tree.mat'), 'classification_tree', 'parent');
end

tree_path = char(tree_path);