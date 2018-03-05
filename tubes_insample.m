function tubes_insample()
%% Function to take one element at a time, train tree model and check element classification
% Parameters:
% 

% Open matlab pool with local configuration
%matlabpool

% Original dataset file
%original_dataset_path = 'Dataset/seb_cell1.mat';
%original_dataset_path = 'Dataset/seb_cell1_norm.mat';
% original_dataset_path = 'Dataset/seb_cell1_norm_lpl_mzl_cd10.mat';
% original_dataset_path = 'Dataset/iris_train_set.mat';
original_dataset_path = 'Dataset/seb_cell_2015_07_23_norm_lpl+mzl.mat';

%%%%%%%% Markers by tube %%%%%%%
% Separate attributes per tube
% Substituting Kappa and Lambda median fluorescence for simulated
% Kappa/Lambda
% Tube 1: CD20 CD45 CD5 CD19 CD38 KL
%marc{1} = [ 4 5 11 14 16 27 ];
%marc{1} = [ 27 ];
marc{1} = [ 4 5 11 14 16 ];
%
%% Tube 2: CD20 CD45 CD23 CD10 CD79b CD19 CD200 CD43
marc{2} = [ 1 4 5 6 8 13 14 18];
%
%% Tube 3: CD20 CD45 CD31 CD305(LAIR1) CD11c CD19 SmIgM CD81														
marc{3} = [3 4 5 10 14 19 23 24];
%
%% Tube 4: CD20 CD45 CD103 CD95 CD22 CD19 CD185(CXCR5) CD49d
marc{4} = [2 4 5 7 14 15 20 21];
%
%% Tube 5: CD20 CD45 CD62L CD39 HLADR CD19 CD27
marc{5} = [4 5 9 12 14 17 22];

% All tubes:
% marc{1} = 1:24;

%Load data
fname=fullfile(original_dataset_path);
load(fname);
classification_output = {};
train_set{10} = [];
original_train_set = train_set;
marc_label_par = marc_label;
classification_output = cell(1,1);
test_set = cell(1,size(train_set,2));
tic;

class_list =  [1 2 3 4 5 6 7 8];

for k=1:length(class_list)
    i = class_list(k);
    classification_array = {};
    parfor element_index=1:size(train_set{i},1)
        classified = false;
        round = 1;
        to_remove = [];
        borders_path = strcat('Datasets/Dataset/borders_matrix_tube1.mat');
        marc_all = cell(1,1);
        marc_all{1} = marc{1};
        while ~classified
            % Init parfor loop variables
            train_set = original_train_set;
            for classes=1:length(to_remove)
                if to_remove(classes) == 1
                    train_set{classes} = [];
                end
            end
            to_remove = [];
            test_set = cell(1,size(train_set,2));
            % Assign values
            element = train_set{i}(element_index,:);
            test_set{i} = element;
            % Train model
            fmt = sprintf('%d_%d', i, element_index);
            [tree_model, marc_tree] = get_trees2(train_set, marc_all, marc_label_par, fmt, borders_path, round);
            model = tree_model(size(tree_model,1),:);
            marc_model = marc_tree(size(tree_model,1),:);
            % Get element classification
            classification = get_tree_classification(test_set, model, marc_model);
            marc_old = marc_all{1};
            
            output = clean_multiple_output([classification(3)])
            output = output{1};
            
            for output_classes=1:size(original_train_set, 2)
                to_remove = vertcat(to_remove, isempty(strfind(output, num2str(output_classes))));
            end
            
            added_2 = false;
            if length(output) == 1
%                 disp('classified')
                classified = true;
%                 output
            else
                if (~isempty(strfind(output, '4')) || ~isempty(strfind(output, '8')))
                    marc_all{1} = unique(horzcat(marc{1}, marc{2}))
%                     output
%                     disp('adding tube 2')
                    borders_path = strcat('Datasets/Dataset/borders_matrix_tube1,2.mat');
                    added_2 = true;
                end
                if (~isempty(strfind(output, '6')))
                    marc_all{1} = unique(horzcat(marc{1}, marc{3}))
%                     output
                    if added_2 == true
                        borders_path = strcat('Datasets/Dataset/borders_matrix_tube1,2,3.mat');
                    else
                        borders_path = strcat('Datasets/Dataset/borders_matrix_tube1,3.mat');
                    end
%                     disp('adding tube 3')
                end
                if (isequal(marc_all{1}, marc_old))
                    marc_all{1} = unique(horzcat(marc{1}, marc{2}, marc{3}, marc{4}, marc{5}))
%                     disp('adding all')
                    if (isequal(marc_all{1}, marc_old))
                        classified = true
%                         disp('nothing else to do')
                    end
                    borders_path = strcat('Datasets/Dataset/borders_matrix_all.mat');
%                     output
                end
            end
%             disp('done')
            round = round + 1;
        end
        
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
[h1, h2] = plot_category_confusion(target_in, output_in);
fig_name1 = strcat('Resultados/confusion_mat_all');
fig_name2 = strcat('Resultados/confusion_mat');
saveas(h1, fig_name1,'fig');
saveas(h1, fig_name1,'png');
saveas(h2, fig_name2,'fig');
saveas(h2, fig_name2,'png');

t = toc;
disp('Elapsed Time: ')
disp(t);