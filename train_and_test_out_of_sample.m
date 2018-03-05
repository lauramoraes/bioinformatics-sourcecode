function [classification, accuracy] = train_and_test_out_of_sample(train_share, repetitions, original_dataset_path)
%% Train and test different combinations of the dataset
% Parameters:
% dataset_path: path to whole dataset
% train_share: proportion in which the dataset will be split
% repetition: how many times the dataset will be split

% Original dataset file
if ~exist('original_dataset_path','var')
    original_dataset_path = 'Dataset/iris_train_set.mat';
end

marc{1} = 1:4;
base_save_folder = 'Out of sample';
accuracy = [];

if ~exist(base_save_folder, 'dir')
    mkdir(base_save_folder)
end

%% For each time, run test data
for i=1:repetitions
    
    %Load data
    fname=fullfile(original_dataset_path);
    load(fname);

    % Separate in two sets
    [train_set, test_set] = separate_train_and_test(train_set, train_share);
    save_folder = strcat(base_save_folder, '/', num2str(i), '/');
    
    if ~exist(save_folder, 'dir')
        mkdir(save_folder)
    end
    
    save(strcat(save_folder, 'dataset.mat'), 'train_set', 'test_set', 'marc_label');
    
    [tree_model, marc_tree] = get_trees(strcat(save_folder, 'dataset.mat'), save_folder)
    tree = tree_model(size(tree_model,1),:)
    marc = marc_tree(size(marc_tree,1), :);
    classification = get_tree_classification(test_set, tree, marc);
    
    save(strcat(save_folder, 'tree_model.mat'), 'tree_model'), 'marc_tree';
    save(strcat(save_folder, 'classification.mat'), 'classification');
    
    %% Plot confusion matrix
    target_in = classification(:,2);
    output_in = classification(:,3);
    
    confusion_matrix = confusionmat(target_in, output_in);
    
    total_percent = (trace(confusion_matrix))/sum(confusion_matrix(:))*100;
    accuracy = vertcat(accuracy, total_percent);
    
    [target, output] = prepare_confusionmat(target_in, output_in);
    
    h = plotconfusion(target, output);
    classification
    
    fig_name = strcat(save_folder, '/confusion_mat');
    tree_name = strcat(save_folder, '/singleton_tree');
    
    saveas(h, fig_name,'fig');
    saveas(h, fig_name,'png');
    close(h);
   
    test_set_size = [];
    for i=1:size(test_set,2)
        test_set_size(i) = size(test_set{i},1);
    end
    h = plot_tree(tree{1}, test_set_size);
    saveas(h, tree_name,'fig');
    saveas(h, tree_name,'png');
    close(h);
end

save(strcat(base_save_folder, '/accuracy.mat'), 'accuracy');