function learning_curves(n_start, n_max, step, dataset, test_set, marc_label, marc, name)
%% Iterate until reach n_max, starting from n_start with step

EXPERIMENTS = 10;
accuracy_array = zeros(EXPERIMENTS, ceil((n_max-n_start)/step));
accuracy_array_multiple = zeros(EXPERIMENTS, ceil((n_max-n_start)/step));

idx = 1;
for n=n_start:step:n_max

    % Name round
    element_index = sprintf('%s_%d', name, n);

    for j=1:EXPERIMENTS
        
        % Set folders
        base_dataset_folder = strcat('Datasets/', element_index, '/Round', num2str(j), '/');
        if ~exist(base_dataset_folder, 'dir')
            mkdir(base_dataset_folder)
        end
        base_folder = strcat('Resultados/', element_index, '/');
        base_save_folder = strcat('Resultados/', element_index, '/Round', num2str(j), '/');
        if ~exist(base_save_folder, 'dir')
            mkdir(base_dataset_folder)
        end

        % Separate equal number of instances for each class
        for i=1:size(dataset,2)
            list_index = randperm(size(dataset{i}, 1));
            if (n > size(dataset{i},1))
                train_set{i} = dataset{i}(list_index(1:end), :);
            else
                train_set{i} = dataset{i}(list_index(1:n), :);
            end
        end
        original_dataset_path = strcat(base_dataset_folder, '/train_set.mat');
        borders_matrix_path = strcat(base_dataset_folder,'/borders_matrix.mat');
        
        % Train model
        save(original_dataset_path, 'train_set', 'test_set', 'marc_label', '-mat');
        borders_in_sample(original_dataset_path, marc{1}, marc_label, borders_matrix_path)
        [tree_model, marc_tree] = get_trees2(train_set, marc, marc_label, element_index, borders_matrix_path, j, true);
        % Small hack to use round as j. We need to shift model back to
        % first position
        model{1, 1} = tree_model{j, 1};
        marc_temp{1} = marc_tree{j};
        tree_model = model;
        marc_tree{1} = marc_temp{1};
        save(strcat(base_dataset_folder, '/tree_model.mat'), 'tree_model', 'marc_tree');

        % Test model
        classification_matrix = get_tree_classification(test_set, tree_model(size(tree_model,1)), marc_tree);
        save(strcat(base_dataset_folder, '/classification_single.mat'), 'classification_matrix');

        % Get results
        target_in = classification_matrix(:,2);
        output_in = classification_matrix(:,3);
        output = clean_multiple_output(output_in);
        [target, output_single, output_multiple] = get_confusion_mat(target_in, output);
        
        % Get results considering correct only single outputs
        confusion_matrix = confusionmat(target, output_single);
        accuracy = sum(diag(confusion_matrix))/size(output,1);
        accuracy_array(j, idx) = accuracy;
        save(strcat(base_folder, '/accuracy.mat'), 'accuracy_array');
        
        % Get results considering correct multiple outputs as well
        confusion_matrix_multiple = confusionmat(target, output_multiple);
        accuracy = sum(diag(confusion_matrix_multiple))/size(output,1);
        accuracy_array_multiple(j, idx) = accuracy;
        save(strcat(base_folder, '/accuracy_multiple.mat'), 'accuracy_array_multiple');


        % Plot results
        [h1, h2] = plot_category_confusion(target_in, output_in);
        fig_name1 = strcat(base_save_folder, '/confusion_single');
        fig_name2 = strcat(base_save_folder, '/confusion_multiple');
        saveas(h1, fig_name1,'fig');
        saveas(h1, fig_name1,'png');
        saveas(h2, fig_name2,'fig');
        saveas(h2, fig_name2,'png');
        close all;

    end
    idx = idx + 1;
end