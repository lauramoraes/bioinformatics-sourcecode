function [tree_model, marc_tree] = get_trees3(original_dataset_path, verbose)
%% Function to run trees in sequence, using what is left from one tree to
%% start another
% Parameters:
% original_dataset_path: path to dataset
% verbose: display or not info during training. Default: true

% Original dataset file
if ~exist('original_dataset_path','var')
    original_dataset_path = 'Dataset/seb_cell2.mat';
end
if ~exist('verbose','var')
    verbose = true;
end

% Initial values    
first_list_path = 'Datasets/Dataset/first_list.mat';
stop = 0.2;

%Load data
fname=fullfile(original_dataset_path);
load(fname);

%%%%%%%% Markers by tube %%%%%%%
% Separate attributes per tube
% Substituting Kappa and Lambda median fluorescence for simulated
% Kappa/Lambda
% Tube 1: CD20 CD45 CD5 CD19 CD38 KL
%marc{1} = [ 4 5 11 14 16 27 ];
%marc{1} = [ 4 5 11 14 16 ];

% Tube 2: CD20 CD45 CD23 CD10 CD79b CD19 CD200 CD43
%marc{2} = [ 1 4 5 6 8 13 14 19 ];

% Tube 3: CD20 CD45 CD31 CD305(LAIR1) CD11c CD19 SmIgM CD81														
marc{1} = [ 3 4 5 10 14 21 25 26];

% Tube 4: CD20 CD45 CD103 CD95 CD22 CD19 CD185(CXCR5) CD49d
marc{2} = [ 2 4 5 7 14 15 22 23];

% Tube 5: CD20 CD45 CD62L CD39 HLADR CD19 CD27
marc{3} = [4 5 9 12 14 18 24];

removed_ds = cell(1, size(train_set,2));
for j=1:size(train_set, 2)
    %removed_ds{j} = zeros(1,size(train_set{j},2));
    removed_ds{j} = double.empty(0, size(train_set{j},2));
end
removed_flag = true;
round=1;

%%%%%%%%%%%%%%%%%
%% ALG1-RODADA %%
%%%%%%%%%%%%%%%%%
while removed_flag
    % Round
    sprintf('Removing round %d', round);
    
    %Load data
    fname=fullfile(original_dataset_path);
    load(fname);    
    
    % Base paths
    base_save_folder = strcat('Resultados/Round', num2str(round), '/');
    base_node_folder = strcat('Resultados Node/Round', num2str(round), '/');
    base_dataset_folder = strcat('Datasets/Round', num2str(round), '/');

    % Prepare first dataset (model root)
    % Remove removed from dataset
    for j=1:size(train_set, 2)
        train_set{j} = train_set{j}(~ismember(train_set{j}, removed_ds{j}, 'rows'),:);
    end
    
    dataset_path = strcat(base_dataset_folder, '/1/');
    if ~exist(dataset_path, 'dir')
        mkdir(dataset_path)
    end
    train_set{10} = [];
    dataset_path = strcat(dataset_path, 'train_set.mat');
    save(dataset_path, 'train_set', 'marc_label');
    
    % Initial conditions
    i=1;
    tree=1;
    separated_tree = false;
    removed_flag = false;
    %%%%%%%%%%%%%%%
    %% ALG1-TUBO %%
    %%%%%%%%%%%%%%%
    while i<=size(marc, 2) && ~all(cellfun(@isempty,train_set))
        
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

        %%%%%%%%%%%%%%%%%
        %% ALG1-ARVORE %%
        %%%%%%%%%%%%%%%%%
        [train_set, conf_remaining, removed, classes, found_singleton] = find_singleton(dataset_path, first_list_path, save_folder, node_result, stop, marc{i});
        tree_model{round, tree} = classes;
        marc_tree{round, tree} = marc{i};

        if ~found_singleton && size(classes,1) == 1
            [pathstr,name,ext] = fileparts(dataset_path);
            dataset_path_marc = strcat(pathstr, '/', name, '_marc', ext);
            [rem_class, rem_index] = remove_closest_element(dataset_path_marc, classes);
            %train_set = conf_remaining;
            removed_ds{rem_class} = vertcat(removed_ds{rem_class}, train_set{rem_class}(rem_index,:));
            train_set{rem_class}(rem_index,:) = [];
            fprintf('Element %d from class %d removed\n', rem_index, rem_class);
            % Re-run the whole tree with the same markers
            i = i-1;
        elseif ~found_singleton
            fprintf('STOPPED BEFORE SINGLETON')
        end
        
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
    save('Datasets/Dataset/removed', 'removed_ds');
    round = round + 1;
end
save('Datasets/Dataset/tree_model.mat', 'tree_model', 'marc_tree');
