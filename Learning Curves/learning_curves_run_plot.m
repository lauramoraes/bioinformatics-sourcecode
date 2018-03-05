function learning_curves_run_plot(n_start, n_max, step, name)
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
        base_folder = strcat('Resultados/', element_index, '/');
        base_save_folder = strcat('Resultados/', element_index, '/Round', num2str(j), '/');
        
        %Load data
        fname=fullfile(base_dataset_folder, '/classification_single.mat');
        load(fname);

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