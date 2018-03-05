function [classification, accuracy] = test_out_of_sample(tree_list, test_set)

marc{1} = 1:26;
save_folder = 'Arvores'
accuracy = [];

%% For each tree, run test data
for i=1:size(tree_list,1)
    tree = recover_childs(tree_list(i));
    classification = get_tree_classification(test_set, tree, marc);
    
    %% Plot confusion matrix
    target_in = classification(:,2);
    output_in = classification(:,3);
    
    confusion_matrix = confusionmat(target_in, output_in);
    
    total_percent = (trace(confusion_matrix))/sum(confusion_matrix(:))*100;
    accuracy = vertcat(accuracy, total_percent);
    
    [target, output] = prepare_confusionmat(target_in, output_in);
    
    h = plotconfusion(target, output);
    
    fig_name = strcat(save_folder, '/1confusion_mat');
    tree_name = strcat(save_folder, '/1singleton_tree');
    i=2;
    while exist(strcat(fig_name, '.fig'), 'file')
        fig_name = strcat(save_folder, '/', int2str(i), 'confusion_mat');
        tree_name = strcat(save_folder, '/', int2str(i), 'singleton_tree');
        i = i+1;
    end
    saveas(h, fig_name,'fig');
    saveas(h, fig_name,'png');
    close(h);
   
    h = plot_tree(tree{1}, [50 50 50 50 50 50 50 50 50]);
    saveas(h, tree_name,'fig');
    saveas(h, tree_name,'png');
    close(h);
end

save(strcat(save_folder, '/accuracy.mat'), 'accuracy');