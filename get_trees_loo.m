function [tree_model, marc_tree] = get_trees2(original_train_set, marc, marc_label, element_index, borders_path, round, verbose)
%% Function to run trees in sequence, using what is left from one tree to
%% start another
% Parameters:
% original_train_set: dataset to train model
% marc: markers used in each tree
% marc_label: markers name (all)
% element_index: unique id identifying element position to create writing
% folder
% verbose: display or not info during training. Default: false

%original_train_set{10} = [];

if ~exist('round','var')
    round = 1;
end
if ~exist('verbose','var')
    verbose = false;
end

if ~exist('borders_path','var')
    borders_path = strcat('Datasets/', element_index, '/borders_matrix.mat');
end
first_list_path = 'Datasets/Dataset/first_list.mat';
stop = 0.2;

removed_ds = cell(1, size(original_train_set,2));
for j=1:size(original_train_set, 2)
    removed_ds{j} = double.empty(0, size(original_train_set{j},2));
    total(j) = size(original_train_set{j},1);
end
removed_flag = true;
% round=1;

while removed_flag
    % Round
    sprintf('Removing round %d', round);
    
    train_set = original_train_set;    
    
    % Base paths
    base_save_folder = strcat('Resultados/', element_index, '/Round', num2str(round), '/');
    base_node_folder = strcat('Resultados Node/', element_index, '/Round', num2str(round), '/');
    base_dataset_folder = strcat('Datasets/', element_index, '/Round', num2str(round), '/');
    
%     borders_path = strcat('Datasets/Dataset/borders_matrix.mat');

    % Prepare first dataset (model root)
    % Remove removed from dataset
    for j=1:size(train_set, 2)
        train_set{j} = train_set{j}(~ismember(train_set{j}, removed_ds{j}, 'rows'),:);
    end
    
    dataset_path = strcat(base_dataset_folder, '/1/');
    if ~exist(dataset_path, 'dir')
        mkdir(dataset_path)
    end

    dataset_path = strcat(dataset_path, 'train_set.mat');
    save(dataset_path, 'train_set', 'marc_label');
    
    % Initial conditions
    i=1;
    tree=1;
    separated_tree = false;
    removed_flag = false;
    
    while i<=size(marc, 2)
        
        % Init condition per tree
        found_singleton = false;

        % Final results folder
        save_folder = strcat(base_save_folder, num2str(tree));
        if ~exist(save_folder, 'dir')
            mkdir(save_folder)
        end
        % Node results folder
        node_result = strcat(base_node_folder, num2str(tree));
        if ~exist(node_result, 'dir')
            mkdir(node_result)
        end

        %[train_set, conf_remaining, removed, classes, found_singleton] = find_singleton(dataset_path, first_list_path, save_folder, node_result, stop, marc{i}, total, verbose);
        disp('cheguei aqui')S
        [train_set, conf_remaining, removed, classes, found_singleton] = find_singleton(dataset_path, first_list_path, borders_path, save_folder, node_result, stop, marc{i}, total, false);
        tree_model{round, tree} = classes;
        marc_tree{round, tree} = marc{i};
        
        % Join removed dataset
        if found_singleton
            for j=1:size(train_set, 2)
                removed_ds{j} = vertcat(removed_ds{j}, removed{j});
                if ~isempty(removed{j})
                    removed_flag = true;
                end
            end
        end

        % Increase marker
        i = i+1;
        % Increase tree id
        tree = tree+1;

        % Next tree dataset
        dataset_path = strcat(base_dataset_folder, num2str(tree));
        if ~exist(dataset_path, 'dir')
            mkdir(dataset_path)
        end
        dataset_path = strcat(base_dataset_folder, num2str(tree), '/train_set.mat');
        save(dataset_path, 'train_set', 'marc_label');

    end
    save(strcat(base_dataset_folder,'/removed.mat'), 'removed_ds');
    round = round + 1;
end
save(strcat('Datasets/', element_index, '/tree_model.mat'), 'tree_model', 'marc_tree');
