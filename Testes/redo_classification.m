function classification_matrix = redo_classification()
%% Redo tree_classification

original_dataset_path = 'Datasets/Dataset/seb_cell_2015_07_23_norm_lpl+mzl.mat';

%Load data
fname=fullfile(original_dataset_path);
load(fname, 'train_set');


classification_matrix = [];
listing = dir('.');

% listing = [struct('name', 'Datasets/3_2')];

for i=3:length(listing)
% for i=1:length(listing)
    if strcmp(listing(i).name, 'Dataset')
        break
    end
    fname=fullfile(strcat(listing(i).name, '/tree_model.mat'));
    load(fname);
    
%     element_index = strsplit(listing(i).name, '_')
%     name = strsplit('/', listing(i).name)
%     element_index = strsplit('_', name{2});
    element_index = strsplit('_', listing(i).name);
    test_set = cell(1);
    test_set{str2double(element_index(1))} = [train_set{str2double(element_index(1))}(str2double(element_index(2)),:)];
    
    classif_temp = get_tree_classification(test_set, tree_model, marc_tree);
    
    classification_matrix = vertcat(classification_matrix, classif_temp);
end

%% Plot confusion matrix
target_in = classification_matrix(:,2);
output_in = classification_matrix(:,3);

% confusion_matrix = confusionmat(target_in, output_in);
% [target, output] = prepare_confusionmat(target_in, output_in);
% h = plotconfusion(target, output);
[h1, h2] = plot_category_confusion(target_in, output_in);
fig_name1 = strcat('../Resultados/confusion_mat_all');
fig_name2 = strcat('../Resultados/confusion_mat');
saveas(h1, fig_name1,'fig');
saveas(h1, fig_name1,'png');
saveas(h2, fig_name2,'fig');
saveas(h2, fig_name2,'png');


