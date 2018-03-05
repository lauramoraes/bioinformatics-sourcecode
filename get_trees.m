function [tree_model, marc_tree, acc1, acc2] = get_trees(original_dataset_path, stop, markers, original_save_folder, verbose)
%% Function to run trees in sequence, using what is left from one tree to
%% start another
% Parameters:
% original_dataset_path: path to dataset
% verbose: display or not info during training. Default: true

% Original dataset file
if ~exist('original_dataset_path','var')
    %original_dataset_path = 'Dataset/seb_cell1.mat';
%          original_dataset_path = 'Dataset/seb_cell1_norm.mat';
    %     original_dataset_path = 'Dataset/resampled_seb_cell1_norm.mat';
%     original_dataset_path = 'Dataset/seb_cell1_norm_lpl_mzl_cd10.mat';
%     original_dataset_path = 'Dataset/iris_train_set.mat';
%     original_dataset_path = 'Dataset/seb_cell_2015_07_01_norm_lpl+mzl.mat';
   %original_dataset_path = 'Dataset/seb_cell_2015_07_23_norm_lpl+mzl.mat';
%     original_dataset_path = 'Dataset/seb_cell_2015_05_20_norm_5_classes.mat';
%   original_dataset_path = 'Dataset/cal_housing.mat';
   %original_dataset_path = 'Dataset/digits.mat';
   %original_dataset_path = 'Dataset/usps_divided.mat';
%   original_dataset_path = 'Dataset/pendigits_divided.mat';
%    original_dataset_path = 'Dataset/mnist_divided.mat';
    original_dataset_path = 'Dataset/glass_norm.mat';
    %original_dataset_path = 'Dataset/heart_norm.mat';
%    original_dataset_path = 'Dataset/cooking_fold_2.mat';
    %original_dataset_path = 'Dataset/cooking_divided.mat';


end
if ~exist('original_save_folder','var')
    %original_dataset_path = 'Dataset/seb_cell1.mat';
%          original_dataset_path = 'Dataset/seb_cell1_norm.mat';
    %     original_dataset_path = 'Dataset/resampled_seb_cell1_norm.mat';
%     original_dataset_path = 'Dataset/seb_cell1_norm_lpl_mzl_cd10.mat';
    original_save_folder = '.';
end

if ~exist('verbose','var')
    verbose = true;
end

if ~exist('stop', 'var')
    stop = 0.1;
end

% Initial values    
first_list_path = 'Datasets/Dataset/first_list.mat';
borders_path = 'Datasets/Dataset/borders_matrix.mat';

%Load data
fname=fullfile(original_dataset_path);
load(fname);
%train_set{10} = [];

%%%%%%%% Markers by tube %%%%%%%
% Separate attributes per tube
% Substituting Kappa and Lambda median fluorescence for simulated
% Kappa/Lambda
% Tube 1: CD20 CD45 CD5 CD19 CD38 KL
%marc{1} = [ 27 ];
%marc{1} = [ 4 5 11 14 16 ];
%marc{2} = [ 4 5 11 14 16 ];
%
%% Tube 2: CD20 CD45 CD23 CD10 CD79b CD19 CD200 CD43
%marc{2} = [ 1 4 5 6 8 13 14 18];
%
%% Tube 3: CD20 CD45 CD31 CD305(LAIR1) CD11c CD19 SmIgM CD81														
%marc{3} = [3 4 5 10 14 19 23 24];
%
%% Tube 4: CD20 CD45 CD103 CD95 CD22 CD19 CD185(CXCR5) CD49d
%marc{4} = [2 4 5 7 14 15 20 21];
%
%% Tube 5: CD20 CD45 CD62L CD39 HLADR CD19 CD27
%marc{5} = [4 5 9 12 14 17 22];

% All tubes:
% marc{1} = 1:24;
if ~exist('markers', 'var')
    element = train_set{1}(1,:);
    markers = 1:size(element,2);
end
    
marc{1} = markers;

removed_ds = cell(1, size(train_set,2));
for j=1:size(train_set, 2)
    removed_ds{j} = double.empty(0, size(train_set{j},2));
    total(j) = size(train_set{j},1);
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
    %train_set{10} = [];
    
    % Base paths
    base_save_folder = strcat(original_save_folder, '/Resultados/Round', num2str(round), '/');
    base_node_folder = strcat(original_save_folder, '/Resultados Node/Round', num2str(round), '/');
    base_dataset_folder = strcat(original_save_folder,'/Datasets/Round', num2str(round), '/');

    % Prepare first dataset (model root)
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
    %%%%%%%%%%%%%%%
    %% ALG1-TUBO %%
    %%%%%%%%%%%%%%%
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

        %%%%%%%%%%%%%%%%%
        %% ALG1-ARVORE %%
        %%%%%%%%%%%%%%%%%
        %[train_set, conf_remaining, removed, classes, found_singleton] = find_singleton(dataset_path, first_list_path, save_folder, node_result, stop, marc{i}, total, true, 0.65);
        [train_set, conf_remaining, removed, classes, found_singleton] = find_singleton(dataset_path, first_list_path, borders_path, save_folder, node_result, stop, marc{i}, total, true);
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
    save('Datasets/Dataset/removed', 'removed_ds');
    round = round + 1;
end
save('Datasets/Dataset/tree_model.mat', 'tree_model', 'marc_tree');

%Load data
fname=fullfile(original_dataset_path);
load(fname);
%train_set{10} = [];

classification_matrix = get_tree_classification(test_set, tree_model(size(tree_model,1)), marc_tree, original_dataset_path);
target_in = classification_matrix(:,2);
output_in = classification_matrix(:,3);

% confusion_matrix = confusionmat(target_in, output_in);
% [target, output] = prepare_confusionmat(target_in, output_in);
% h = plotconfusion(target, output);
[h1, h2, acc1, acc2] = plot_category_confusion(target_in, output_in);
fig_name1 = strcat('Resultados/confusion_outsample_all');
fig_name2 = strcat('Resultados/confusion_outsample');
saveas(h1, fig_name1,'fig');
saveas(h1, fig_name1,'png');
saveas(h2, fig_name2,'fig');
saveas(h2, fig_name2,'png');
save('Datasets/Dataset/classification_outsample.mat', 'classification_matrix');
