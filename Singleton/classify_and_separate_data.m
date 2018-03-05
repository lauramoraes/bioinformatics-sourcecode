function [node, classification,  classification_tree, remaining, removed, conf_remaining, found_singleton] = classify_and_separate_data(best_class, train_set, node, train_set_init, original_class, original_index, X_init, X_unbalanced, total, save_folder, save_folder_base, borders_path, stop, marc, min_w, verbose, classification_tree, tree_index, remaining, conf_remaining, removed, found_singleton, leaf)
%% Classify and separate into left and right train sets, 

% [classification, X, X_unbalanced, Y, mu, sigma] = generate_classification(best_class, train_set, 'lasso_regression', true, min_w);
[classification, X, X_unbalanced, Y, mu, sigma] = generate_classification(best_class, train_set, 'lasso_regression', false, min_w, leaf);
if verbose
    classification.confusion_matrix
end
node.mu = mu;
node.sigma = sigma;

%%%%%%%%%%%%%%%%%%%%
%% ALG3-PRECISION %%
%%%%%%%%%%%%%%%%%%%%
classified_any = all(any(classification.confusion_matrix, 1));
% 
if classified_any
% classified_any = find(classification.precision == 100);
% if ~(isempty(classified_any))
    
    % Split data into to send to the left and right children
    [node, train_set_ldata, train_set_rdata] = separate_data(node, X, classification, train_set_init, original_class, original_index, X_unbalanced, total);
    
    % If it's just one case, show what case it is (left leaf) (deprecated)
     lsingle_elements = [];
%     % If it's just one case, show what case it is (right leaf) (deprecated)
     rsingle_elements = [];
    
    % Save datasets
    train_set = train_set_ldata';
    save(strcat(save_folder, '/ldata.mat'), 'train_set');
    train_set = train_set_rdata';
    save(strcat(save_folder, '/rdata.mat'), 'train_set');

    %%%%%%%%%%%%%%%%%
    %% ALG3-LCHILD %%
    %%%%%%%%%%%%%%%%%
    % Do the same for the children
    train_set = train_set_ldata';
    [node.lchild, classification_tree, lremaining, lremoved, conf_remaining, found_singleton] = create_classification_tree(strcat(save_folder, '/ldata.mat'), strcat(save_folder, '/first_list.mat'), borders_path, save_folder_base, node.llist, total, stop, marc, min_w, verbose, classification_tree, tree_index, lsingle_elements, remaining, conf_remaining, removed, found_singleton, leaf);
    
    %%%%%%%%%%%%%%%%%
    %% ALG3-RCHILD %%
    %%%%%%%%%%%%%%%%%
    train_set = train_set_rdata';
    [node.rchild, classification_tree, rremaining, rremoved, conf_remaining, found_singleton] = create_classification_tree(strcat(save_folder, '/rdata.mat'), strcat(save_folder, '/first_list.mat'), borders_path, save_folder_base, node.rlist, total, stop, marc, min_w, verbose, classification_tree, tree_index, rsingle_elements, remaining, conf_remaining, removed, found_singleton, leaf);
    
    % Join remaining elements dataset
    for r_index=1:size(remaining,2)
        if ~isempty(lremaining{r_index})
            if ~isempty(remaining{r_index})
                remaining{r_index} = union(remaining{r_index}, lremaining{r_index}, 'rows');
            else
                remaining{r_index} = lremaining{r_index};
            end
        end
        if ~isempty(rremaining{r_index})
            if ~isempty(remaining{r_index})
                remaining{r_index} = union(remaining{r_index}, rremaining{r_index}, 'rows');
            else
                remaining{r_index} = rremaining{r_index};
            end
        end
    end
    % Join removed elements dataset
    for r_index=1:size(removed,2)
        if ~isempty(lremoved{r_index})
            if ~isempty(removed{r_index})
                removed{r_index} = union(removed{r_index}, lremoved{r_index}, 'rows');
            else
                removed{r_index} = lremoved{r_index};
            end
        end
        if ~isempty(rremoved{r_index})
            if ~isempty(removed{r_index})
                removed{r_index} = union(removed{r_index}, rremoved{r_index}, 'rows');
            else
                removed{r_index} = rremoved{r_index};
            end
        end
    end
else
    %%%%%%%%%%%%%%%%%%%%%%
    %% ALG3-NOPRECISION %%
    %%%%%%%%%%%%%%%%%%%%%%
    % Stop! Didn't find 100% precision. Just show accuracy.
    node.accuracy = classification.accuracy;
    % Get remaining elements
%     if size(unique(available_classes),1) == 2
    if isempty(node.listA)
        conf_remaining = train_set_init;
    else
        remaining = train_set_init;
    end
end

% Confusion matrix for node
node.confusion_matrix = classification.confusion_matrix; 
node.accuracy = classification.accuracy;
% Normalized weight vector for node
node.weight = classification.w_norm;
node.model = classification.w;

% Update tree
classification_tree(tree_index) = node;