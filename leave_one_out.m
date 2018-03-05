function [acc1, acc2] = leave_one_out(original_dataset_path, stop, markers)
%% Function to take one element at a time, train tree model and check element classification
% Parameters:
% 

% Open matlab pool with local configuration
%matlabpool
if ~exist('original_dataset_path','var')
% Original dataset file
%original_dataset_path = 'Dataset/seb_cell1.mat';
%original_dataset_path = 'Dataset/seb_cell1_norm.mat';
% original_dataset_path = 'Dataset/seb_cell1_norm_lpl_mzl_cd10.mat';
% original_dataset_path = 'Dataset/iris_train_set.mat';
original_dataset_path = 'Dataset/seb_cell_2015_07_23_norm_lpl+mzl.mat';
%    original_dataset_path = 'Dataset/glass_norm.mat';
end

if ~exist('stop', 'var')
    stop = 0.1
end

%%%%%%%% Markers by tube %%%%%%%
% Separate attributes per tube
% Substituting Kappa and Lambda median fluorescence for simulated
% Kappa/Lambda
% Tube 1: CD20 CD45 CD5 CD19 CD38 KL
%marc{1} = [ 4 5 11 14 16 ];
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
%marc{1} = 1:9;

%Load data
fname=fullfile(original_dataset_path);
load(fname);
classification_output = {};
%train_set{10} = [];
original_train_set = train_set;
marc_label_par = marc_label;
%classification_output = cell(1,size(train_set,2));
classification_output = cell(1,1);
test_set = cell(1,size(train_set,2));
tic;

if ~exist('markers', 'var')
    element = train_set{1}(1,:);
    markers = 1:size(element,2);
end
    
marc{1} = markers;


class_list =  1:size(train_set,2);

%for i=1:size(train_set,2)
for k=1:length(class_list)
    i = class_list(k);
    classification_array = {};
    parfor element_index=1:size(train_set{i},1)
    %for element_index=1:size(train_set{i},1)
        % Init parfor loop variables
        train_set = original_train_set;
        test_set = cell(1,size(train_set,2));
        % Assign values
        element = train_set{i}(element_index,:);
        test_set{i} = element;
        train_set{i}(element_index,:) = [];
        % Train model
        fmt = sprintf('%d_%d', i, element_index);
        [tree_model, marc_tree] = get_trees2(train_set, marc, marc_label_par, fmt, stop);
        model = tree_model(size(tree_model,1),:);
        marc_model = marc_tree(size(tree_model,1),:);
        % Get element classification
        classification = get_tree_classification(test_set, model, marc_model, original_dataset_path);
        classification_array(element_index,:) = classification;
    end

    classification_output{i} = classification_array;
    save(strcat('Datasets/Dataset/classification_', num2str(i), '.mat'), 'classification_array');
end

save('Datasets/Dataset/classification_output.mat', 'classification_output');
classification_matrix = [];
for i=1:size(classification_output,2)
    classification_matrix = [classification_matrix; classification_output{i}];
end
save('Datasets/Dataset/classification_output.mat', 'classification_output', 'classification_matrix');

% Print classification matrix
% fid = fopen('leave_one_out.csv','w');
%colheadings = {'Row', 'Target','Output', 'Original Index'};
% displaytable(classification_matrix, [], [], 'd');
% displaytable(classification_matrix, [], [], 'd', [], fid, ';', ';');
% fclose(fid);

%% Plot confusion matrix
target_in = classification_matrix(:,2);
output_in = classification_matrix(:,3);

% confusion_matrix = confusionmat(target_in, output_in);
% [target, output] = prepare_confusionmat(target_in, output_in);
% h = plotconfusion(target, output);
[h1, h2, acc1, acc2] = plot_category_confusion(target_in, output_in);
fig_name1 = strcat('Resultados/confusion_mat_all');
fig_name2 = strcat('Resultados/confusion_mat');
saveas(h1, fig_name1,'fig');
saveas(h1, fig_name1,'png');
saveas(h2, fig_name2,'fig');
saveas(h2, fig_name2,'png');

t = toc;
disp('Elapsed Time: ')
disp(t);