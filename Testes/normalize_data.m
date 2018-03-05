function X_norm = normalize_data(train_set)
    %% Normalize data using uniform distribution %%
    % Parameters:
    % train_set: Cell set to be normalized divided in classes.
    
    X_total = [];
    X_norm = cell(1, size(train_set,2));
    
    % Join data
    for i=1:size(train_set,2)
        X_total = vertcat(X_total,train_set{i});
    end
    
    max_val = max(X_total);
    max_vals = repmat(max_val,size(X_total,1),1);
    min_val = min(X_total);
    min_vals = repmat(min_val,size(X_total,1),1);
    X_total = 10*(X_total - min_vals)./(max_vals-min_vals);
    
    % Separate data per class
    index_init = 1;
    for i=1:size(train_set,2)
        index_end = index_init + size(train_set{i}, 1)-1;
        X_norm{i} = X_total(index_init:index_end, :);
        index_init = index_end + 1;
    end
end
    
    